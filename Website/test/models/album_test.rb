require 'test_helper'

class AlbumTest < ActiveSupport::TestCase
	def setup
		path = File.join(Rails.root, 'test/fixtures/image_32x32.png')
		stub_request(:get, 'http://foo.com/img1.jpg').to_return(:body => File.new(path), :status => 200)
		stub_request(:get, 'http://foo.com/img2.jpg').to_return(:body => File.new(path), :status => 200)
		
		@hash = {
			name: 'Foo',
			popularity: '123',
			artist: 'Damian Marley',
			id: '123',
			source: :lastfm,
			images: [
				{ url: 'http://foo.com/img1.jpg' },
				{ url: 'http://foo.com/img2.jpg' },
			],
			url: 'http://foo.com/album1',
			type: :album
		}
		
		super
	end
	
	test "should create album" do
		a = nil
		assert_difference 'Album.count', 1, "Didn't create new album" do
			a = Album.find_or_create_by_hash(@hash)
		end
		assert a, "Didn't return album"
		assert_equal @hash[:name], a.title, "Didn't set title"
		
		assert_equal @hash[:artist], a.artists.first.name, "Didn't set artist"
		assert_equal @hash[:images].length, a.images.count, "Didn't set images"
		assert_equal 1, a.sources.count, "Didn't set source"
		
		s = a.sources[0]
		
		assert_equal @hash[:popularity].to_f, s.popularity, "Didn't set source popularity"
		assert_equal @hash[:id], s.foreign_id, "Didn't set source id"
		assert_equal @hash[:url], s.foreign_url, "Didn't set source url"
		assert_equal @hash[:source], s.name, "Didn't set source name"
	end
	
	test "should create album with existing artist" do
		artist = artists(:bob_marley)
		a = nil
		@hash[:artist] = artist.name
		assert_no_difference 'Artist.count', "Created new artist" do
			a = Album.find_or_create_by_hash(@hash)
		end
		assert_equal artist, a.artists.first, "Didn't set artist"
	end
	
	test "should find album" do
		album = nil
		a = albums(:relapse)
		@hash[:name] = a.title
		@hash.delete(:artist)
		@hash[:artists] = []
		artists_before = a.artists.count
		a.artists.each { |artist| @hash[:artists] << artist.name }
		assert_no_difference 'Album.count', "Created new album" do
		assert_no_difference 'Artist.count', "Created more artists" do
			album = Album.find_or_create_by_hash(@hash)
		end
		end
		assert_equal a, album, "Didn't return correct album"
		assert_equal artists_before, album.artists.count, "Changed number of artists"
		
		s = a.sources.where(name: :lastfm).first
		assert s, "Didn't set source"
		assert_equal @hash[:popularity].to_f, s.popularity, "Didn't set source popularity"
		assert_equal @hash[:id], s.foreign_id, "Didn't set source id"
		assert_equal @hash[:url], s.foreign_url, "Didn't set source url"
		assert_equal @hash[:source].to_s, s.name, "Didn't set source name"
	end
	
	test "should add songs" do
		a = albums(:recovery)
		s = songs(:not_afraid)
		@hash[:name] = a.title
		@hash[:artist] = a.artists.first.name
		@hash[:songs] = [
			{
				name: 'Foo',
				artist: 'Bar',
				length: 123,
				path: 'foo.mp3'
			},
			{ path: s.sources.first.path, length: s.sources.first.length }
		]
		album = nil
		assert_difference "Artist.count", 1, "Didn't create exactly one artist" do
		assert_difference "Song.count", 1, "Didn't create exactly one song" do
			album = Album.find_or_create_by_hash(@hash)
		end
		end
		assert_equal 4, album.songs.count, "Didn't assign both songs"
	end

	test "should not re-add existing songs" do
		a = albums(:recovery)
		s = songs(:one_love)
		@hash[:name] = a.title
		@hash[:artist] = a.artists.first.name
		@hash[:songs] = [
			{
				name: 'Foo',
				artist: 'Bar',
				length: 123,
				path: 'foo.mp3'
			},
			{ path: s.sources.first.path }
		]
		album = Album.find_or_create_by_hash(@hash)
		assert_equal 3, album.songs.count, "Didn't assign the song"
	end
	
	test "should get top albums" do
		a = Album.top.limit(3)
		assert_equal 3, a.length, "Didn't return three top albums"
		assert_instance_of Album, a.first, "Didn't return albums"
		assert a[0].listens.count >= a[1].listens.count, "Top albums not in order (first and second)"
		assert a[1].listens.count == a[2].listens.count, "Top albums not in order (second and third, listens)"
		assert a[1].popularity > a[2].popularity, "Top albums not in order (second and third, popularity)"
	end
	
	test "should get popularity" do
		a = albums(:best_of_bob_marley)
		p = 0
		a.songs.each do |s|
			s.sources.each do |src|
				p += src.normalized_popularity
			end
		end
		assert_equal p, a.popularity, "Popularity isn't the combined popularity of the songs"
		
		a = albums(:recovery)
		p = 0
		a.sources.each do |s|
			p += s.normalized_popularity
		end
		assert_equal p, a.popularity, "Popularity isn't the combined popularity of the sources"
	end
	
	test 'should get artist names' do
		a = albums(:relapse)
		assert_equal 'Bob Marley and Eminem', a.artist_names
	end
end
