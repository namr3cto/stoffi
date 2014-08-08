require 'test_helper'

class SongTest < ActiveSupport::TestCase
	def setup
		@youtube_json = {
			'items' => [
				{
					'id' => '123',
					'snippet' =>
					{
						'title' => 'SomeArtist - SomeTitle',
						'thumbnails' =>
						{
							'default' => { 'url' => 'http://foo.com/bar' }
						}
					},
					'contentDetails' =>
					{
						'duration' => 'PT1M5S'
					},
					'statistics' =>
					{
						'viewCount' => '321'
					}
				}
			]
		}
		@soundcloud_json = {
			"title" => "SomeArtist - SomeTitle",
			"permalink_url" => "http://example.com/foo",
			"duration" => "96000",
			"genre" => "somegenre",
			"artwork_url" => "http://example.com/foo.jpg",
			"user" => {
				"name" => "someuser"
			}
		}
	end
	
	def stub_youtube
		stub_request(:any, /https:\/\/www.googleapis.com\/.*/).
			to_return(:body => @youtube_json.to_json, :status => 200)
	end
	
	def stub_soundcloud
		stub_request(:any, /https:\/\/api.soundcloud.com\/.*/).
			to_return(:body => @soundcloud_json.to_json, :status => 200)
	end
	
	test "should create song" do
		assert_difference('Song.count', 1, "Didn't create song") do
		p = Song.create()
		end
	end
	
	test "should get new local song" do
		assert_difference('Song.count', 1, "Didn't create song") do
			s = Song.get(nil, {title: 'foobar', path: '/foo/bar.mp3'})
			assert_equal "foobar", s.title, "Didn't set the correct title"
			assert_equal '/foo/bar.mp3', s.sources.first.foreign_id, "Didn't set the source id"
			assert_equal 'local', s.sources.first.name, "Didn't set the source name"
		end
	end
	
	test "should get youtube song" do
		stub_youtube
		assert_difference('Song.count', 1, "Didn't create song") do
			s = Song.get(nil, {path: "stoffi:track:youtube:123"})
			assert_equal "SomeTitle", s.title, "Didn't set the correct title"
		end
	end
	
	test "should get new soundcloud song" do
		stub_soundcloud
		assert_difference('Song.count', 1, "Didn't create song") do
			s = Song.get(nil, {path: "stoffi:track:soundcloud:abc"})
			assert_equal "SomeTitle", s.title, "Didn't set the correct title"
		end
	end
	
	test "should add new song to user" do
		user = users(:alice)
		assert_difference('user.songs.count', 1, "Didn't add song to user") do
			s = Song.get(user, {path: "foo"})
		end
	end
	
	test "should get existing file song" do
		song = songs(:not_afraid)
		src = song.sources.first
		path = "stoffi:track:#{src.name}:#{src.foreign_id}"
		assert_no_difference('Song.count', "Created song") do
			s = Song.get(nil, {path: path, length: song.length})
			assert_equal song.id, s.id, "Didn't return the existing song"
		end
	end
	
	test "should get existing youtube song" do
		song = songs(:one_love)
		src = song.sources.first
		path = "stoffi:track:#{src.name}:#{src.foreign_id}"
		assert_no_difference('Song.count', "Created song") do
			s = Song.get(nil, {path: path})
			assert_equal song.id, s.id, "Didn't return the existing song"
		end
	end
	
	test "should add existing streaming song to user" do
		user = users(:alice)
		song = songs(:one_love)
		src = song.sources.first
		path = "stoffi:track:#{src.name}:#{src.foreign_id}"
		assert_difference('user.songs.count', 1, "Didn't add song to user") do
			s = Song.get(user, {path: path})
		end
	end
	
	test "should not add existing streaming song to user" do
		user = users(:alice)
		song = songs(:one_love)
		src = song.sources.first
		path = "stoffi:track:#{src.name}:#{src.foreign_id}"
		user.songs << song
		assert_no_difference('user.songs.count', "Added song to user") do
			s = Song.get(user, {path: path})
		end
	end
	
	test "should parse title" do
		artist, title = Song.parse_title("foobar - a great song")
		assert_equal "foobar", artist
		assert_equal "a great song", title
		
		artist, title = Song.parse_title("foobar - a great song [official]")
		assert_equal "foobar", artist
		assert_equal "a great song", title
		
		artist, title = Song.parse_title("foobar - a great song (LYRICS)")
		assert_equal "foobar", artist
		assert_equal "a great song", title
		
		artist, title = Song.parse_title("foobar - a great song official video")
		assert_equal "foobar", artist
		assert_equal "a great song", title
		
		artist, title = Song.parse_title("a great song by foobar")
		assert_equal "foobar", artist
		assert_equal "a great song", title
		
		artist, title = Song.parse_title("a great song, by foobar")
		assert_equal "foobar", artist
		assert_equal "a great song", title
		
		artist, title = Song.parse_title("foobar \"a great song\"")
		assert_equal "foobar", artist
		assert_equal "a great song", title
	end
end
