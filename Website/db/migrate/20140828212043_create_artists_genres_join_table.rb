class CreateArtistsGenresJoinTable < ActiveRecord::Migration
  def change
    create_join_table :artists, :genres do |t|
      # t.index [:artist_id, :genre_id]
      t.index [:genre_id, :artist_id], unique: true
    end
  end
end
