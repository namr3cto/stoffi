class CreatePerformancesJoinTable < ActiveRecord::Migration
  def change
    create_join_table :artists, :events, table_name: :performances do |t|
      t.index [:artist_id, :event_id], unique: true
      t.index [:event_id, :artist_id], unique: true
    end
  end
end
