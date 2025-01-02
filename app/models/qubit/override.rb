# == Schema Information
#
# Table name: qubit_overrides
#
#  id               :integer          not null, primary key
#  subject_type     :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  overrider_id     :integer          not null
#  qubit_test_id    :integer
#  qubit_variant_id :integer
#  subject_id       :integer
#
# Indexes
#
#  index_qubit_overrides_on_overrider_id      (overrider_id)
#  index_qubit_overrides_on_qubit_test_id     (qubit_test_id)
#  index_qubit_overrides_on_qubit_variant_id  (qubit_variant_id)
#  index_qubit_overrides_on_subject           (subject_type,subject_id)
#
# Foreign Keys
#
#  overrider_id  (overrider_id => qubit_users.id)
#
module Qubit
  class Override < ApplicationRecord
    belongs_to :overrider, class_name: Qubit.user_class, foreign_key: :overrider_id
    belongs_to :test, class_name: Qubit::Test.name, foreign_key: :qubit_test_id
    belongs_to :variant, class_name: Qubit::Variant.name, foreign_key: :qubit_variant_id
    belongs_to :subject, polymorphic: true
  end
end
