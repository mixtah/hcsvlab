class AddUniqueFullNameToUsers < ActiveRecord::Migration
  def change
    add_index :users, [:first_name, :last_name], name: "unique_full_name_on_users", unique: true
  end
end
