module Qubit
  class Condition
    # Leaf nodes
    attr_reader :name, :klass, :description

    # Non-leaf nodes
    attr_reader :operation, :children

    def self.method(name:, klass:, description:)
      Condition.new(name: name, klass: klass, description: description)
    end

    def self.parse(klass, condition_string)
      ConditionParser.new(klass).parse(condition_string)
    end

    def initialize(operation: nil, children: nil, name: nil, klass: nil, description: nil)
      @operation = operation
      @children = children
      @name = name
      @klass = klass 
      @description = description

      validate!
    end

    def call(obj)
      if leaf?
        condition = ConditionMixin.conditions.find { |c| c.klass == klass && c.name == name }
        raise "Condition #{name} not found on #{klass}" unless condition
        method = klass.instance_method(name)
        method.bind(obj).call
      else
        case operation
        when :and
          children.all? { |child| child.call(obj) }
        when :or
          children.any? { |child| child.call(obj) }
        when :not
          !children.first.call(obj)
        else
          raise "Invalid operation: #{operation}"
        end
      end
    end

    def leaf?
      operation.nil?
    end

    private

    def validate!
      if leaf?
        raise ArgumentError, "Leaf nodes require name" unless name
        raise ArgumentError, "Leaf nodes cannot have children" if children
      else
        raise ArgumentError, "Non-leaf nodes require operation and children" unless operation && children
        raise ArgumentError, "Non-leaf nodes cannot have name, klass or description" if name || klass || description
        
        case operation
        when :not
          raise ArgumentError, "Not operation requires exactly one child" unless children.size == 1
        when :and, :or
          raise ArgumentError, "And/Or operations require at least one child" if children.empty?
        else
          raise ArgumentError, "Invalid operation: #{operation}"
        end
      end
    end
  end
end
