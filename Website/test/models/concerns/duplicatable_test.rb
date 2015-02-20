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
			dup.save
		end
		end
	end
	
	test "should be recursive" do
		a = artists(:eminem)
		b = artists(:bob_marley)
		c = artists(:damian_marley)
		d = artists(:coldplay)
		
		a.duplicate_of b
		b.duplicate_of c
		c.duplicate_of d
		a.save
		b.save
		c.save
		
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
			a.save	
		end
		
		assert_difference "c.duplicates.count", +1 do
			b.duplicate_of c
			b.save	
		end
	end
	
	test "should combine relations" do
		a = songs(:one_love)
		b = songs(:not_afraid)
		combined = a.listens.count + b.listens.count
		a.duplicate_of b
		a.save
		
		assert_equal 1, b.duplicates.length
		assert_equal combined, b.listens.count
	end
	
end