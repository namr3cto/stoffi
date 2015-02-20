class AddArchetypeToEvents < ActiveRecord::Migration
  def change
    add_reference :events, :archetype, polymorphic: true, index: true
  end
end
