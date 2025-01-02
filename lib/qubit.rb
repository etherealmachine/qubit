require "qubit/version"
require "qubit/engine"

module Qubit
  mattr_accessor :user_class do 
    'Qubit::User'
  end
  mattr_accessor :current_user do
    lambda { Qubit.user_class.constantize.first }
  end
end
