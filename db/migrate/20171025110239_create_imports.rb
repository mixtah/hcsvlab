class CreateImports < ActiveRecord::Migration
  def change
    create_table :imports do |t|
      t.references :collection
      t.references :user
      t.string :filename
      t.string :directory
      t.string :options
      t.string :metadata
      t.boolean :extracted
      t.timestamps
    end
  end
end
