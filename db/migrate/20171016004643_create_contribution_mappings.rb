class CreateContributionMappings < ActiveRecord::Migration
  def change
    create_table :contribution_mappings do |t|
      t.references :contribution
      t.references :item
      t.references :document

      t.timestamps
    end
    add_index :contribution_mappings, :contribution_id
    add_index :contribution_mappings, :item_id
    add_index :contribution_mappings, :document_id
    add_index :contribution_mappings, [:contribution_id, :document_id], unique: true
  end
end
