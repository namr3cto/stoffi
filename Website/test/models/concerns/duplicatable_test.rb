require 'test_helper'

class DuplicatableTest < ActiveSupport::TestCase
	
	test "should filter" do
		artist = artists(:bob_marley)
		master = songs(:one_love)
		dup = Song.create(title: 'One Love / People Get Ready')
		assert_difference "artist.songs.count", +1 do
			dup.artists << artist
		end
		
		assert_difference "artist.songs.count", -1 do
		assert_no_difference "artist.songs.unscoped.count" do
			dup.duplicate_of master
		end
		end
	end
	
	test "should be transitive" do
		a = artists(:eminem)
		b = artists(:bob_marley)
		c = artists(:damian_marley)
		d = artists(:coldplay)
		
		a.duplicate_of b
		b.duplicate_of c
		c.duplicate_of d
		
		assert_equal d, a.archetype
		assert_equal 3, d.duplicates.count
	end
	
	test "should be marked as duplicate" do
		a = albums(:relapse)
		b = albums(:recovery)
		
		assert_not a.duplicate?, "a marked as duplicate"
		a.duplicate_of b
		assert a.duplicate?, "a not marked as duplicate"
		assert a.duplicate_of?(b), "a not marked as duplicate of b"
		assert_not b.duplicate_of?(a), "b marked as duplicate of a"
	end
	
	test "should count duplicates" do
		a = songs(:one_love)
		b = songs(:not_afraid)
		c = songs(:no_woman_no_cry)
		
		assert_equal 0, c.duplicates.count
		
		assert_difference "c.duplicates.count", +1 do
			a.duplicate_of c
		end
		
		assert_difference "c.duplicates.count", +1 do
			b.duplicate_of c
		end
	end
	
	test "should combine has_many relation" do
		a = songs(:one_love)
		b = songs(:not_afraid)
		combined = a.listens.count + b.listens.count
		a.duplicate_of b
		
		assert_equal 1, b.duplicates.length
		assert_equal combined, b.listens.count
	end
	
	test "should combine has_many :as relation" do
		a = songs(:one_love)
		b = songs(:not_afraid)
		combined = a.shares.count + b.shares.count
		a.duplicate_of b
		assert_equal combined, b.shares.count
	end
	
	test "should combine has_many :through relation" do
		a = artists(:bob_marley)
		b = artists(:eminem)
		combined = a.listens.count + b.listens.count
		a.duplicate_of b
		assert_equal combined, b.listens.count
	end
	
	test "should combine habtm relation" do
		song_a = songs(:one_love)
		song_b = songs(:not_afraid)
		artist = artists(:damian_marley)
		song_a.artists << artist
		song_b.artists << artist
		song_a.duplicate_of song_b
		
		checked = []
		(song_a.artists + song_b.artists).each do |a|
			next if a.in? checked
			assert_includes song_b.artists, a, "Artist #{a} not included in song #{song_b}"
			checked << a
		end
		song_b.artists.each do |a|
			assert_includes checked, a, "Artist #{a} should not be included in song #{song_b}"
		end
		assert_equal checked.size, song_b.artists.count, "There are duplicates"
	end
	
	test "should fail to duplicate different models" do
		assert_raise(TypeError) do
			Song.first.duplicate_of Artist.first
		end
	end
	
	test "should fail to combine non-existing association" do
		assert_raise(ArgumentError) do
			Song.include_associations_of_dups :listens, :this_relation_doesnt_exist, :shares
		end
	end
end