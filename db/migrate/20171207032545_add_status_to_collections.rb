class AddStatusToCollections < ActiveRecord::Migration
  def change
    add_column :collections, :status, :string, :default => 'RELEASED'
  end
end
