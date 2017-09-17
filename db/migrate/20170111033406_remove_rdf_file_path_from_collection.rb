class RemoveRdfFilePathFromCollection < ActiveRecord::Migration
  def up
    remove_column :collections, :rdf_file_path
  end

  def down
    add_column :collections, :rdf_file_path, :string
  end
end
