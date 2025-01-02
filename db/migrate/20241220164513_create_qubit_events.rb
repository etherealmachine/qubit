class CreateQubitEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :qubit_events do |t|
      t.belongs_to :qubit_variant, null: true
      t.references :subject, polymorphic: true, null: true, index: true
      t.string :event_type, index: true
      t.json :details

      t.timestamps
    end
  end
end
