# == Schema Information
#
# Table name: qubit_users
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
require "test_helper"

module Qubit
  class UserTest < ActiveSupport::TestCase
    setup do
      @user = Qubit::User.create!
    end

    test "has admin condition" do
      assert @user.respond_to?(:admin?)
    end

    test "has dau condition" do 
      assert @user.respond_to?(:dau?)
    end

    test "has mau condition" do
      assert @user.respond_to?(:mau?) 
    end

    test "has paid condition" do
      assert @user.respond_to?(:paid?)
    end
  end
end
