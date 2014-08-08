class AddLengthToSources < ActiveRecord::Migration
  def change
    add_column :sources, :length, :decimal
    Song.all.each do |song|
      song.sources.all.each { |s| s.length = song.length }
    end
  end
end
