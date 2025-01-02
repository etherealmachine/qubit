class CreateQubitUsers < ActiveRecord::Migration[7.1]
  def change
    user_class = Qubit.user_class.constantize
    unless ActiveRecord::Base.connection.table_exists? user_class.table_name
      create_table :qubit_users do |t|
        t.timestamps
      end
    end
  end
end
