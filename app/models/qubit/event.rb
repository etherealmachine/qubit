# == Schema Information
#
# Table name: qubit_events
#
#  id               :integer          not null, primary key
#  details          :json
#  event_type       :string
#  subject_type     :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  qubit_variant_id :integer
#  subject_id       :integer
#
# Indexes
#
#  index_qubit_events_on_event_type        (event_type)
#  index_qubit_events_on_qubit_variant_id  (qubit_variant_id)
#  index_qubit_events_on_subject           (subject_type,subject_id)
#
module Qubit
  class Event < ApplicationRecord
    belongs_to :subject, polymorphic: true
    belongs_to :variant, class_name: Qubit::Variant.name, foreign_key: :qubit_variant_id
  end
end
