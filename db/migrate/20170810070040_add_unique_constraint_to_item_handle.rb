class AddUniqueConstraintToItemHandle < ActiveRecord::Migration
  def change
    remove_index :items, :name => "index_items_on_handle"
    add_index :items, [:handle], :name => "index_items_on_handle", unique: true
  end
end
