# == Schema Information
#
# Table name: qubit_variants
#
#  id            :integer          not null, primary key
#  description   :string
#  name          :string
#  parameters    :json
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  qubit_test_id :integer
#
# Indexes
#
#  index_qubit_variants_on_qubit_test_id  (qubit_test_id)
#
module Qubit
  class Variant < ApplicationRecord
    belongs_to :test, class_name: Qubit::Test.name, foreign_key: :qubit_test_id
    has_many :events, class_name: Qubit::Event.name, foreign_key: :qubit_variant_id
  end
end
