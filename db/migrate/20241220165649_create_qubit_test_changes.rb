class CreateQubitTestChanges < ActiveRecord::Migration[7.1]
  def change
    create_table :qubit_test_changes do |t|
      t.belongs_to :qubit_test, null: true
      t.references :user
      t.string :change_type
      t.json :details

      t.timestamps
    end
  end
end
