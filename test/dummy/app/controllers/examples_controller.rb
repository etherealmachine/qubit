class ExamplesController < ApplicationController
  def show
    @example = Qubit::Test.find(params[:id])
  end
end
