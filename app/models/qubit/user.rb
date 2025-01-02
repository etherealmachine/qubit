# == Schema Information
#
# Table name: qubit_users
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "qubit/condition_mixin"
require "qubit/user_mixin"

module Qubit
  class User < ApplicationRecord
    self.table_name = "qubit_users"

    include Qubit::ConditionMixin
    include Qubit::UserMixin

    condition def admin?
      true
    end, "User is an admin"

    condition def dau?
      true
    end, "User is a daily active user"

    condition def mau?
      true
    end, "User is a monthly active user"

    condition def paid?
      true
    end, "User has paid"

    condition def beta_tester?
      true
    end, "User is enrolled in the beta testing program"
  end
end
