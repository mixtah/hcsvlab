class CreateContributions < ActiveRecord::Migration
  def change
    create_table :contributions do |t|
      t.string :name
      t.references :owner, references: :users
      t.references :collection
      t.text :description

      t.timestamps
    end
    add_index :contributions, :name, :unique => true
    add_index :contributions, :owner_id
    add_index :contributions, :collection_id
  end
end
