require_relative 'concerns/qubit_user_class_helper'

class CreateQubitTests < ActiveRecord::Migration[7.1]
  include QubitUserClassHelper
  
  def change
    user_class, primary_key_type = get_user_class_details
    
    create_table :qubit_tests do |t|
      t.string :name
      t.string :status
      t.references :owner, null: false, type: primary_key_type
      t.string :description
      t.string :condition
      t.string :subject_type
      t.references :control, null: true
      t.json :traffic_allocation
      t.references :holdout, null: true

      t.timestamps
    end

    add_index :qubit_tests, :status
  end
end
