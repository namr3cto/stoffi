class AddArchetypeToSongs < ActiveRecord::Migration
  def change
    add_reference :songs, :archetype, polymorphic: true, index: true
  end
end
