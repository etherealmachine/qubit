module Qubit
  class HoldoutsController < ApplicationController
    def index
      @holdouts = Test.
        where(id: Test.where.not(holdout_id: nil).
        select(:holdout_id)).
        where(status: :open)
    end
  end
end

