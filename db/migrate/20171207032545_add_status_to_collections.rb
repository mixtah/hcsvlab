class AddStatusToCollections < ActiveRecord::Migration
  def change
    add_column :collections, :status, :string, :default => 'DRAFT'
  end
end
