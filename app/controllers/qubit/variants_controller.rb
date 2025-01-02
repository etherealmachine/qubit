module Qubit
  class VariantsController < ApplicationController
    before_action :set_test_and_variant

    def close
      @test.close!(variant: @variant)
      redirect_to @test, notice: "Test was successfully closed with variant #{@variant.name}."
    end

    def override
      @test.override!(Qubit.current_user.call, @variant)
      redirect_back fallback_location: @test, notice: "Successfully overrode variant to #{@variant.name}."
    end

    private

    def set_test_and_variant
      @test = Test.find(params[:test_id])
      @variant = @test.variants.find(params[:id])
    end
  end
end