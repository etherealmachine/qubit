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
require "test_helper"

module Qubit
  class CensusTest < ActiveSupport::TestCase
    # test "the truth" do
    #   assert true
    # end
  end
end
