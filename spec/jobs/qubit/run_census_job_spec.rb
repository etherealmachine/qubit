require "test_helper"

module Qubit
  class RunCensusJobTest < ActiveSupport::TestCase
    setup do
      @user1 = create(:qubit_user, paid: true, last_seen_at: 1.hour.ago, beta_tester: true)
      @user2 = create(:qubit_user, paid: false, last_seen_at: 2.days.ago, beta_tester: false) 
      @user3 = create(:qubit_user, paid: true, last_seen_at: 10.days.ago, beta_tester: false)
      
      @census = create(:qubit_census, subject_type: 'Qubit::User', sample_size: 3)
      
      Qubit::User.stubs(:order).returns(Qubit::User)
      Qubit::User.stubs(:limit).returns([@user1, @user2, @user3])
    end

    test "counts paid users correctly" do
      @census.update(condition: 'paid?')
      RunCensusJob.perform_now(@census)
      
      assert_equal 2, @census.matched # user1 and user3 are paid
      assert_equal 3, @census.surveyed
      assert_equal 'completed', @census.status
    end

    test "counts daily active users correctly" do
      @census.update(condition: 'dau?')
      RunCensusJob.perform_now(@census)
      
      assert_equal 1, @census.matched # only user1 seen in last day
      assert_equal 3, @census.surveyed
      assert_equal 'completed', @census.status
    end

    test "counts monthly active users correctly" do
      @census.update(condition: 'mau?')
      RunCensusJob.perform_now(@census)
      
      assert_equal 2, @census.matched # user1 and user2 seen in last month
      assert_equal 3, @census.surveyed
      assert_equal 'completed', @census.status
    end

    test "counts beta testers correctly" do
      @census.update(condition: 'beta_tester?')
      RunCensusJob.perform_now(@census)
      
      assert_equal 1, @census.matched # only user1 is beta tester
      assert_equal 3, @census.surveyed
      assert_equal 'completed', @census.status
    end

    test "sets status to running while job is in progress" do
      @census.update(condition: 'paid?')
      
      # Stub the final status update to verify the running status
      @census.expects(:update!).with(status: 'running').once
      @census.expects(:update!).with(status: 'completed').once
      
      RunCensusJob.perform_now(@census)
    end

    test "marks census as failed and reraises error when error occurs" do
      Qubit::Condition.stubs(:parse).raises(StandardError)

      assert_raises StandardError do
        RunCensusJob.perform_now(@census)
      end

      assert_equal 'failed', @census.status
    end
  end
end