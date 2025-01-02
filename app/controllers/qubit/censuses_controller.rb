module Qubit
  class CensusesController < ApplicationController
    def index
      @censuses = Census.all
    end
  end
end
