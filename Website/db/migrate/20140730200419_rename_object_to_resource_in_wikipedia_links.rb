class RenameObjectToResourceInWikipediaLinks < ActiveRecord::Migration
  def change
    rename_column :wikipedia_links, :object_id, :resource_id
    rename_column :wikipedia_links, :object_type, :resource_type
  end
end
