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
		super
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
			assert_equal :local, s.sources.first.name, "Didn't set the source name"
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
			s = Song.get(user, {path: "foo.mp3"})
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
	
	test "should get existing song with same artists and title" do
		song = songs(:not_afraid)
		assert_no_difference('Song.count', "Created song") do
			s = Song.get(nil, {title: song.title.downcase, artist: song.artists.join(', ').upcase})
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
	
	test "should get song from search result" do
		hit = {
			fullname: "Eminem - Relapse",
			name: "Relapse",
			type: :song,
			artist: "Eminem",
			artists: ["Eminem"],
			popularity: 123,
			length: 92,
			path: 'stoffi:track:youtube:foo',
		}
		s = nil
		assert_difference('Song.count', 1, "Didn't create song") do
			s = Song.get(nil, hit, false)
		end
		assert_equal 'Relapse', s.title, "Didn't create song with correct title"
		assert_equal 1, s.artists.count, "Didn't assign any artist to song"
		assert_equal 'Eminem', s.artists[0].name, "Didn't assign song to correct artist"
		assert_equal 123, s.sources[0].popularity, "Didn't assign correct popularity"
		assert_equal 92, s.sources[0].length, "Didn't assign correct length"
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
		
		artist, title = Song.parse_title("foo (bar)")
		assert_equal "", artist
		assert_equal "foo (bar)", title
		
		artist, title = Song.parse_title("foo - a great song ft. bar")
		assert_equal "foo, bar", artist
		assert_equal "a great song", title
	end
	
	test "should extract artist from hash" do
		name = 'Damian Marley'
		song = { artist: name }
		assert_difference('Artist.count', 1, "Didn't create artist") do
			Song.extract_artists(song)
		end
		a = Artist.last
		assert_equal name, a.name, "Latest artist didn't get the correct name"
	end
	
	test "should extract existing artist from hash" do
		name = 'Eminem'
		song = { artist: name }
		assert_no_difference('Artist.count', "Created new artist") do
			Song.extract_artists(song)
		end
	end
	
	test "should extract artists from hash" do
		song = { artists: ['Eminem', 'Damian Marley', 'Stephen Marley'], artist: 'Foo' }
		assert_difference('Artist.count', 2, "Didn't create two artists") do
			Song.extract_artists(song)
		end
		a = Artist.last
		assert_equal 'Stephen Marley', a.name, "Latest artist didn't get the correct name"
	end
	
	test "should get top songs" do
		s = Song.top.limit 3
		assert_equal 3, s.length, "Didn't return three songs"
		assert s[0].listens.count >= s[1].listens.count, "Top songs not in order (first and second)"
		assert s[1].listens.count >= s[2].listens.count, "Top songs not in order (second and third)"
	end
	
	test "should get top songs for artist" do
		s = artists(:bob_marley).songs.top.limit 3
		assert_equal 3, s.length, "Didn't return three songs"
		assert s[0].listens.count >= s[1].listens.count, "Top songs not in order (first and second)"
		assert s[1].listens.count >= s[2].listens.count, "Top songs not in order (second and third)"
	end
end
