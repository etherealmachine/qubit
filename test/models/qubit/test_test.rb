# == Schema Information
#
# Table name: qubit_tests
#
#  id                 :integer          not null, primary key
#  condition          :string
#  description        :string
#  name               :string
#  status             :string
#  subject_type       :string
#  traffic_allocation :json
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  control_id         :integer
#  holdout_id         :integer
#  owner_id           :integer          not null
#
# Indexes
#
#  index_qubit_tests_on_control_id  (control_id)
#  index_qubit_tests_on_holdout_id  (holdout_id)
#  index_qubit_tests_on_owner_id    (owner_id)
#  index_qubit_tests_on_status      (status)
#
require "test_helper"
require "active_job/test_helper"

module Qubit
  class TestTest < ActiveSupport::TestCase
    include ActiveJob::TestHelper

    def setup_test_with_variants(name: "Test", description: "Test description", variant_count: 2)
      user = Qubit.user_class.constantize.create!
      
      test = Test.create!(
        owner: user,
        name: name,
        description: description
      )

      control = Variant.create!(
        name: 'control',
        description: 'Control variant',
        test: test
      )

      test.update!(control: control)

      variants = []
      variant_count.times do |i|
        variants << Variant.create!(
          name: "variant_#{i + 1}",
          description: "Test variant #{i + 1}",
          test: test
        )
      end

      [test, control, *variants]
    end

    test "creating a test" do
      test, control, variant = setup_test_with_variants(
        name: "Basic Example Test",
        description: "This is an example test with 2 variants",
        variant_count: 1
      )

      assert_equal 2, test.variants.count
    end

    test "launching a test immediately" do
      test, control, variant = setup_test_with_variants(
        name: "Launch Test",
        description: "Test for launching immediately",
        variant_count: 1
      )

      test.launch!

      expected_allocation = {
        control.id.to_s => 50,
        variant.id.to_s => 50
      }

      assert_equal expected_allocation, test.traffic_allocation

      test_change = test.test_changes.last
      assert_equal 'launch', test_change.change_type
      assert_equal expected_allocation, test_change.details
    end

    test "launching a test in canary mode" do
      test, control, variant_a, variant_b = setup_test_with_variants(
        name: "Canary Launch Test",
        description: "Test for launching in canary mode",
        variant_count: 2
      )

      # Launch with 10% total traffic to non-control variants (5% each)
      test.launch!(rollout: 10)

      expected_allocation = {
        control.id.to_s => 90,
        variant_a.id.to_s => 5,
        variant_b.id.to_s => 5
      }

      assert_equal expected_allocation, test.traffic_allocation

      test_change = test.test_changes.last
      assert_equal 'launch', test_change.change_type
      assert_equal expected_allocation, test_change.details
    end

    test "closing a test routes all traffic to specified variant" do
      test, control, variant = setup_test_with_variants(
        name: "Close Test",
        description: "Test for closing and routing traffic",
        variant_count: 1
      )

      # First launch the test normally
      test.launch!

      # Close the test and route all traffic to the variant
      test.close!(variant:)

      expected_allocation = {
        control.id.to_s => 0,
        variant.id.to_s => 100
      }

      assert_equal expected_allocation, test.traffic_allocation

      test_change = test.test_changes.last
      assert_equal 'close', test_change.change_type
      assert_equal expected_allocation, test_change.details
    end

    test "deleting a test deletes all associated records" do
      test, control, variant = setup_test_with_variants(
        name: "Delete Test",
        description: "Test for deleting and cascading",
        variant_count: 1
      )

      # Create some test changes
      test.launch!
      test.close!(variant:)

      # Create a user to be the subject of events
      user = Qubit.user_class.constantize.create!

      # Create some events
      event1 = Qubit::Event.create!(
        variant: control,
        event_type: 'view',
        details: { page: 'home' },
        subject: user
      )
      
      event2 = Qubit::Event.create!(
        variant: variant,
        event_type: 'click',
        details: { button: 'signup' },
        subject: user
      )

      # Store IDs before deletion
      variant_ids = test.variants.pluck(:id)
      test_change_ids = test.test_changes.pluck(:id)
      event_ids = [event1.id, event2.id]

      # Delete the test
      test.destroy

      # Verify test is deleted
      assert_nil Qubit::Test.find_by(id: test.id)

      # Verify variants are deleted
      variant_ids.each do |id|
        assert_nil Qubit::Variant.find_by(id: id)
      end

      # Verify test changes are deleted
      test_change_ids.each do |id|
        assert_nil Qubit::TestChange.find_by(id: id)
      end

      # Events are not deleted immediately but via a background job
      event_ids.each do |id|
        assert_not_nil Qubit::Event.find_by(id: id), "Event should still exist before pruning job runs"
      end

      # Run the pruning job
      PruneEventsJob.perform_later
      perform_enqueued_jobs
      
      # Now verify events are deleted
      event_ids.each do |id|
        assert_nil Qubit::Event.find_by(id: id), "Event should be deleted after pruning job runs"
      end
    end

    test "getting variant for a subject" do
      test, control, variant = setup_test_with_variants(
        name: "Variant Test",
        description: "Test for getting variant for subject",
        variant_count: 1
      )

      # Launch the test to enable variant assignment
      test.launch!

      # Create a new user as the subject
      user = Qubit.user_class.constantize.create!

      # Get variant for the user
      assigned_variant = test.variant_for(user)

      # Verify we got a valid variant back
      assert [control.id, variant.id].include?(assigned_variant.id)
      
      # Verify same user gets same variant on subsequent calls
      assert_equal assigned_variant, test.variant_for(user)
    end

    test "overriding variant for a subject" do
      test, control, variant = setup_test_with_variants(
        name: "Override Test", 
        description: "Test for overriding variant for subject",
        variant_count: 1
      )

      user = Qubit.user_class.constantize.create!

      # Can override before launch
      test.override!(user, variant)
      assert_equal variant, test.variant_for(user)
      assert_equal 1, Event.where(variant: variant, subject: user, event_type: "override").count
      
      # Can override multiple times before launch
      test.override!(user, control)
      assert_equal control, test.variant_for(user)
      assert_equal 1, Event.where(variant: control, subject: user, event_type: "override").count

      # Launch the test
      test.launch!

      # Can override multiple times after launch
      test.override!(user, variant)
      assert_equal variant, test.variant_for(user)
      assert_equal 2, Event.where(variant: variant, subject: user, event_type: "override").count
      
      test.override!(user, control) 
      assert_equal control, test.variant_for(user)
      assert_equal 2, Event.where(variant: control, subject: user, event_type: "override").count

      # Clear override
      test.clear_override!(user)

      # After clearing, gets consistent random assignment
      assigned_variant = test.variant_for(user)
      assert [control.id, variant.id].include?(assigned_variant.id)
      assert_equal 1, Event.where(variant: assigned_variant, subject: user, event_type: "assignment").count
      
      # Subsequent calls use same assignment without creating new events
      assert_equal assigned_variant, test.variant_for(user)
      assert_equal 1, Event.where(variant: assigned_variant, subject: user, event_type: "assignment").count
    end
  end
end
