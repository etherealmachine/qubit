require 'test_helper'
require 'qubit/condition_parser'

module Qubit
  class ConditionParserTest < ActiveSupport::TestCase
    test "parse single condition" do
      result = ConditionParser.parse('condition1')
      
      assert_equal :condition1, result.name
      assert_nil result.klass
    end

    test "parse not condition" do
      result = ConditionParser.parse('!condition1')
      
      assert_equal :not, result.operation
      assert_equal :condition1, result.children[0].name
      assert_nil result.children[0].klass
    end

    test "parse and condition" do
      result = ConditionParser.parse('condition1 && condition2')
      
      assert_equal :and, result.operation
      assert_equal :condition1, result.children[0].name
      assert_equal :condition2, result.children[1].name
      assert_nil result.children[0].klass
      assert_nil result.children[1].klass
    end

    test "parse or condition" do
      result = ConditionParser.parse('condition1 || condition2')
      
      assert_equal :or, result.operation
      assert_equal :condition1, result.children[0].name
      assert_equal :condition2, result.children[1].name
      assert_nil result.children[0].klass
      assert_nil result.children[1].klass
    end

    test "parse complex expression" do
      result = ConditionParser.parse('condition1 && (condition2 || !condition3)')
      
      assert_equal :and, result.operation
      assert_equal :condition1, result.children[0].name
      assert_equal :or, result.children[1].operation
      assert_equal :condition2, result.children[1].children[0].name
      assert_equal :not, result.children[1].children[1].operation
      assert_equal :condition3, result.children[1].children[1].children[0].name
    end

    test "raises error for unmatched parenthesis" do
      assert_raises(ConditionParser::ParserError) do
        ConditionParser.parse('(condition1')
      end
    end
  end
end
