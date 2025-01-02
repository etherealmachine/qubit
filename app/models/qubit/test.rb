# == Schema Information
#
# Table name: qubit_tests
#
#  id                 :integer          not null, primary key
#  condition          :string
#  description        :string
#  name               :string
#  status             :string
#  subject_type       :string
#  traffic_allocation :json
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  control_id         :integer
#  holdout_id         :integer
#  owner_id           :integer          not null
#
# Indexes
#
#  index_qubit_tests_on_control_id  (control_id)
#  index_qubit_tests_on_holdout_id  (holdout_id)
#  index_qubit_tests_on_owner_id    (owner_id)
#  index_qubit_tests_on_status      (status)
#
module Qubit
  class Test < ApplicationRecord
    belongs_to :owner, class_name: Qubit.user_class, foreign_key: :owner_id
    belongs_to :control, class_name: Qubit::Variant.name, foreign_key: :control_id, optional: true
    belongs_to :holdout, class_name: Qubit::Test.name, foreign_key: :holdout_id, optional: true
    has_many :variants, class_name: Qubit::Variant.name, foreign_key: :qubit_test_id, dependent: :destroy
    has_many :test_changes, class_name: Qubit::TestChange.name, foreign_key: :qubit_test_id, dependent: :destroy

    def launch!(rollout: nil)
      transaction do
        variant_count = variants.count
        
        if rollout.nil?
          # Allocate evenly across all variants
          allocation_per_variant = 100.0 / variant_count
          
          self.traffic_allocation = variants.each_with_object({}) do |variant, allocation|
            allocation[variant.id.to_s] = allocation_per_variant
          end
        else
          non_control_variants = variants.where.not(id: control_id)
          
          # Calculate allocation based on rollout percentage
          control_allocation = 100.0 - rollout.to_f
          allocation_per_variant = rollout.to_f / non_control_variants.count
          
          self.traffic_allocation = variants.each_with_object({}) do |variant, allocation|
            allocation[variant.id.to_s] = if variant.id == control_id
              control_allocation
            else
              allocation_per_variant
            end
          end
        end

        self.status = :open
        
        save!
        
        test_changes.create!(
          user: Qubit.current_user.call,
          change_type: 'launch',
          details: traffic_allocation,
        )
      end
    end

    def close!(variant:)
      transaction do
        # Set all variants to 0% traffic except winning variant which gets 100%
        self.traffic_allocation = variants.each_with_object({}) do |v, allocation|
          allocation[v.id.to_s] = v == variant ? 100 : 0
        end

        self.status = :closed
        
        save!
        
        test_changes.create!(
          user: Qubit.current_user.call,
          change_type: 'close',
          details: traffic_allocation,
        )
      end
    end

    def variant_for(subject)
      # Check for override first
      override = Override.find_by(
        subject: subject,
        test: self
      )

      return override.variant if override.present?

      # If test isn't launched, return control variant
      return control unless traffic_allocation.present?

      # Get or create assignment event
      assignment_event = Event.find_or_create_by(
        subject: subject,
        event_type: "assignment"
      ) do |event|
        # Use deterministic hash based on test and subject IDs for consistent assignment
        hash = Digest::MD5.hexdigest("#{id}-#{subject.id}").to_i(16)
        ticket = hash % 100
        running_total = 0

        assigned_variant = nil
        traffic_allocation.each do |variant_id, percentage|
          running_total += percentage.to_f
          if ticket < running_total
            assigned_variant = variants.find(variant_id)
            break
          end
        end

        event.variant = assigned_variant || control
      end

      assignment_event.variant
    end

    def override!(subject, variant)
      # Find or initialize override
      override = Override.find_or_initialize_by(
        overrider: Qubit.current_user.call,
        subject: subject,
        test: self
      )

      # Update variant
      override.variant = variant
      override.save!

      # Create override event
      Event.create!(
        subject: subject,
        variant: variant,
        event_type: "override"
      )

      variant
    end

    def clear_override!(subject)
      # Find and destroy any existing override
      override = Override.find_by(
        subject: subject,
        test: self
      )
      override&.destroy
    end

    def create_census!(sample_size: 100)
      Census.create!(
        name: "Census for #{name}",
        description: "Census for #{name}",
        sample_size:,
        condition:,
        owner:,
      )
    end
  end
end
