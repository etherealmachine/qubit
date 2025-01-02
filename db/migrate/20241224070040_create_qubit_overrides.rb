require_relative 'concerns/qubit_user_class_helper'

class CreateQubitOverrides < ActiveRecord::Migration[7.1]
  include QubitUserClassHelper
  
  def change
    user_class, primary_key_type = get_user_class_details
    
    create_table :qubit_overrides do |t|
      t.belongs_to :qubit_test, null: true
      t.references :overrider, null: false, type: primary_key_type, foreign_key: { to_table: user_class.table_name }
      t.references :subject, polymorphic: true, null: true, index: true
      t.belongs_to :qubit_variant

      t.timestamps
    end
  end
end
