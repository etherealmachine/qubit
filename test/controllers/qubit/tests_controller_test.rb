require "test_helper"

module Qubit
  class TestsControllerTest < ActionDispatch::IntegrationTest
    # Don't
    # include Engine.routes.url_helpers
    # It will pull in methods with test_ and confuse minitest

    setup do
      user = Qubit.user_class.constantize.create!
      @test = Test.create!(name: 'Controller Test', owner: user)
      control = @test.variants.create!(name: 'Control')
      @test.update!(control: control)
      @test.variants.create!(name: 'Variant A')
      @test.variants.create!(name: 'Variant B') 
    end

    test "should get index" do
      get Engine.routes.url_helpers.tests_url(only_path: true)
      assert_response :success
    end

    test "should get new" do
      get Engine.routes.url_helpers.new_test_url(only_path: true)
      assert_response :success
    end

    test "should create test" do
      assert_difference("Test.count") do
        post Engine.routes.url_helpers.tests_url(only_path: true), params: { test: { name: @test.name } }
      end

      assert_redirected_to Engine.routes.url_helpers.test_url(Test.last, only_path: true)
    end

    test "should show test" do
      get Engine.routes.url_helpers.test_url(@test, only_path: true)
      assert_response :success
    end

    test "should get edit" do
      get Engine.routes.url_helpers.edit_test_url(@test, only_path: true)
      assert_response :success
    end

    test "should update test" do
      patch Engine.routes.url_helpers.test_url(@test, only_path: true), params: { test: { name: @test.name } }
      assert_redirected_to Engine.routes.url_helpers.test_url(@test, only_path: true)
    end

    test "should destroy test" do
      assert_difference("Test.count", -1) do
        delete Engine.routes.url_helpers.test_url(@test, only_path: true)
      end

      assert_redirected_to Engine.routes.url_helpers.tests_url(only_path: true)
    end

    test "should launch test" do
      patch Engine.routes.url_helpers.launch_test_url(@test, only_path: true)
      assert_redirected_to Engine.routes.url_helpers.test_url(@test, only_path: true)
      
      @test.reload
      assert_not_nil @test.traffic_allocation, "Traffic allocation should be set after launch"
    end

    test "should launch test with rollout" do
      patch Engine.routes.url_helpers.launch_test_url(@test, only_path: true, canary: true)
      assert_redirected_to Engine.routes.url_helpers.test_url(@test, only_path: true)
      
      @test.reload
      assert_not_nil @test.traffic_allocation, "Traffic allocation should be set after launch"
      
      # Control variant should get 90% traffic
      control_allocation = @test.traffic_allocation[@test.control_id.to_s].to_f
      assert_equal 99, control_allocation, "Control variant should get 90% traffic"
      
      # Other variants should split remaining 10%
      non_control_variants = @test.variants.where.not(id: @test.control_id)
      allocation_per_variant = 1.0 / non_control_variants.count
      non_control_variants.each do |variant|
        assert_equal allocation_per_variant, @test.traffic_allocation[variant.id.to_s].to_f,
          "Non-control variants should split remaining traffic evenly"
      end
    end

    test "should close test with variant" do
      variant = @test.variants.first
      patch Engine.routes.url_helpers.close_test_variant_url(@test, variant, only_path: true)
      assert_redirected_to Engine.routes.url_helpers.test_url(@test, only_path: true)
      
      @test.reload
      assert_not_nil @test.traffic_allocation, "Traffic allocation should be set after close"
      
      # Winning variant should get 100% traffic
      assert_equal 100, @test.traffic_allocation[variant.id.to_s].to_f, "Winning variant should get 100% traffic"
      
      # All other variants should get 0% traffic
      other_variants = @test.variants.where.not(id: variant.id)
      other_variants.each do |other_variant|
        assert_equal 0, @test.traffic_allocation[other_variant.id.to_s].to_f,
          "Other variants should get 0% traffic"
      end
    end

  end
end
