class AddArchetypeToAlbums < ActiveRecord::Migration
  def change
    add_reference :albums, :archetype, polymorphic: true, index: true
  end
end
