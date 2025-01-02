class CreateQubitVariants < ActiveRecord::Migration[7.1]
  def change
    create_table :qubit_variants do |t|
      t.belongs_to :qubit_test, null: true
      t.string :name
      t.string :description
      t.json :parameters

      t.timestamps
    end
  end
end
