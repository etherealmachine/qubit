require "test_helper"
require "qubit/condition_mixin"

module Qubit
  class ConditionMixinTest < ActiveSupport::TestCase
    test "basic condition mixin" do
      klass = Class.new do
        include Qubit::ConditionMixin
        
        condition def example_condition
          true
        end, "Example condition"
      end

      condition = ConditionMixin.conditions.find { |c| c.klass == klass }
      assert_equal(:example_condition, condition.name)
      assert_equal(klass, condition.klass)
      assert_equal("Example condition", condition.description)

      assert_equal(true, condition.call(klass.new))
    end
  end
end
