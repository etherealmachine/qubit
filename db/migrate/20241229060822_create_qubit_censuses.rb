require_relative 'concerns/qubit_user_class_helper'

class CreateQubitCensuses < ActiveRecord::Migration[7.1]
  include QubitUserClassHelper
  
  def change
    user_class, primary_key_type = get_user_class_details
    
    create_table :qubit_censuses do |t|
      t.string :name
      t.references :owner, null: false, type: primary_key_type
      t.string :description
      t.string :condition
      t.string :subject_type
      t.integer :sample_size
      t.decimal :sample_rate
      t.string :status
      t.integer :matched
      t.integer :surveyed

      t.timestamps
    end

    add_index :qubit_censuses, :status
  end
end
