require 'test_helper'

class SourceTest < ActiveSupport::TestCase
	test "should parse path" do
		p = Source.parse_path('stoffi:track:soundcloud:abc')
		assert_equal 'Song', p[:resource]
		assert_equal :soundcloud, p[:source]
		assert_equal 'abc', p[:id]
		
		p = Source.parse_path('stoffi:playlist:youtube:qwe')
		assert_equal 'Playlist', p[:resource]
		assert_equal :youtube, p[:source]
		assert_equal 'qwe', p[:id]
		
		p = Source.parse_path('http://foo.com/song.mp3')
		assert_equal 'Song', p[:resource]
		assert_equal :url, p[:source]
		assert_equal 'http://foo.com/song.mp3', p[:id]
		
		p = Source.parse_path('path/to/playlist.pls')
		assert_equal 'Playlist', p[:resource]
		assert_equal :local, p[:source]
		assert_equal 'path/to/playlist.pls', p[:id]
		
		p = Source.parse_path('http://foo.com/song')
		assert_equal 'Song', p[:resource]
		assert_equal :url, p[:source]
		assert_equal 'http://foo.com/song', p[:id]
	end
	
	test "should create by path" do
		s = nil
		assert_difference "Source.count", 1, "Didn't create new source" do
			s = Source.find_or_create_by_path("stoffi:track:youtube:qwe")
		end
		assert s, "Didn't return source"
		assert_equal :youtube, s.name, "Didn't set name"
		assert_equal 'qwe', s.foreign_id, "Didn't set id"
	end
	
	test "should find by path" do
		src = sources(:no_woman_no_cry_soundcloud)
		path = "stoffi:track:#{src.name}:#{src.foreign_id}"
		s = nil
		assert_no_difference "Source.count", "Created new source" do
			s = Source.find_or_create_by_path(path)
		end
		assert s, "Didn't return source"
		assert_equal s, src, "Didn't return the correct source"
	end
end
