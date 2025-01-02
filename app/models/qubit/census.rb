# == Schema Information
#
# Table name: qubit_censuses
#
#  id           :integer          not null, primary key
#  condition    :string
#  description  :string
#  matched      :integer
#  name         :string
#  sample_rate  :decimal(, )
#  sample_size  :integer
#  status       :string
#  subject_type :string
#  surveyed     :integer
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  owner_id     :integer          not null
#
# Indexes
#
#  index_qubit_censuses_on_owner_id  (owner_id)
#  index_qubit_censuses_on_status    (status)
#
module Qubit
  class Census < ApplicationRecord
    self.table_name = "qubit_censuses"

    belongs_to :owner, class_name: Qubit.user_class

    def run
      Qubit::RunCensusJob.perform_later(self)
    end

    def sample(subject)
      if subject.class.name != self.subject_type
        raise ArgumentError, "Subject class #{subject.class.name} does not match census subject type #{self.subject_type}"
      end

      if condition.call(subject)
        census.matched += 1
      end
      census.surveyed += 1
    end
  end
end
