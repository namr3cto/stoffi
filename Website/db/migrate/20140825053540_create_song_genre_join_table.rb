class CreateSongGenreJoinTable < ActiveRecord::Migration
  def change
    create_join_table :songs, :genres do |t|
      # t.index [:song_id, :genre_id]
      t.index [:genre_id, :song_id], unique: true
    end
  end
end
