require 'qubit/condition'

module Qubit
  module ConditionMixin
    @conditions = []

    def self.conditions
      @conditions
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      def condition(method_name, description)
        original_method = instance_method(method_name)
        
        if original_method.parameters.any?
          raise ArgumentError, "Condition methods cannot take parameters"
        end

        condition = Qubit::Condition.method(
          name: method_name,
          klass: self,
          description: description
        )

        ConditionMixin.conditions << condition
        
        define_method(method_name) do
          original_method.bind(self).call
        end
      end
    end
  end
end