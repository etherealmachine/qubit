require "qubit/condition_mixin"

module Qubit
  class ConditionsController < ApplicationController
    def index
      @conditions = ConditionMixin.conditions
    end
  end
end 