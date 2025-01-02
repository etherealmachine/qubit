module Qubit
  module UserMixin
    extend ActiveSupport::Concern

    included do
      has_many :events, class_name: Qubit::Event.name, foreign_key: :qubit_user_id
      has_many :variants, through: :events, class_name: Qubit::Variant.name
      has_many :tests, through: :variants, class_name: Qubit::Test.name
    end

    # Returns true if this user is currently assigned to the given variant
    def assigned_to?(variant)
      variants.exists?(variant.id)
    end

    # Returns the variant this user is assigned to for the given test, if any
    def variant_for(test)
      variants.find_by(qubit_test_id: test.id)
    end
  end
end 