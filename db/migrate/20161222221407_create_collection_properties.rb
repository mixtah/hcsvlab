class CreateCollectionProperties < ActiveRecord::Migration
  def change
    create_table :collection_properties do |t|
      t.string :property
      t.text :value
      t.references :collection

      t.timestamps
    end
  end
end


