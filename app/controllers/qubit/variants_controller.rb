module Qubit
  class VariantsController < ApplicationController
    before_action :set_test_and_variant, except: [:create]

    def create
      @test = Test.find_by(id: params[:test_id])
      @test.variants.create!(name: "Variant #{@test.variants.count + 1}")
      redirect_back fallback_location: @test, notice: "Created new variant."
    end

    def destroy
      @variant.destroy
      redirect_back fallback_location: @test, notice: "Deleted variant."
    end

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