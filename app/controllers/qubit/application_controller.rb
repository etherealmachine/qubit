module Qubit
  class ApplicationController < ActionController::Base
    before_action :current_user

    def current_user
      Qubit.current_user.call
    end
  end
end
