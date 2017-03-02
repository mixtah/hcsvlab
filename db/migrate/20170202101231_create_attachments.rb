class CreateAttachments < ActiveRecord::Migration
  def change
    create_table :attachments do |t|
      t.string :file
      t.string :file_name
      t.string :content_type
      t.integer :file_size
      t.string :created_by
      t.references :collection

      t.timestamps
    end
    add_index :attachments, :collection_id
  end
end
