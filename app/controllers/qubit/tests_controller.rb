module Qubit
  class TestsController < ApplicationController
    before_action :set_test, only: %i[ show edit launch update destroy ]

    # GET /tests
    def index
      @tests = Test.all
    end

    # GET /tests/1
    def show
    end

    # GET /tests/new
    def new
      @test = Test.new
    end

    # GET /tests/1/edit
    def edit
    end

    # PATCH /tests/1/launch
    def launch
      @test.launch!(rollout: params[:canary] ? 1 : nil)
      redirect_to @test, notice: "Test was successfully launched."
    end

    # POST /tests
    def create
      @test = Test.new(test_params.merge({
        owner: Qubit.current_user.call,
      }))

      if @test.save
        redirect_to @test, notice: "Test was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    # PATCH/PUT /tests/1
    def update
      if @test.update(test_params)
        redirect_to @test, notice: "Test was successfully updated.", status: :see_other
      else
        render :edit, status: :unprocessable_entity
      end
    end

    # DELETE /tests/1
    def destroy
      @test.destroy!
      redirect_to tests_url, notice: "Test was successfully destroyed.", status: :see_other
    end

    private
      # Use callbacks to share common setup or constraints between actions.
      def set_test
        @test = Test.includes(:variants).find(params[:id])
      end

      # Only allow a list of trusted parameters through.
      def test_params
        params.require(:test).permit(:name, :description)
      end
  end
end
