# == Schema Information
#
# Table name: qubit_test_changes
#
#  id            :integer          not null, primary key
#  change_type   :string
#  details       :json
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  qubit_test_id :integer
#  user_id       :integer
#
# Indexes
#
#  index_qubit_test_changes_on_qubit_test_id  (qubit_test_id)
#  index_qubit_test_changes_on_user_id        (user_id)
#
module Qubit
  class TestChange < ApplicationRecord
    belongs_to :user, class_name: Qubit.user_class, foreign_key: :user_id
    belongs_to :test, class_name: Qubit::Test.name, foreign_key: :qubit_test_id
  end
end
