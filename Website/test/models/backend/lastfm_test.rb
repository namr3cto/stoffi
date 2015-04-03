require 'test_helper'
require 'test_helpers/lastfm_helper'

class LastfmTest < ActiveSupport::TestCase
	
	include Backend::Lastfm::TestHelpers
	
	setup do
		stub_lastfm
	end
	
	test 'search for artists' do
		hits = Backend::Lastfm.search('foo', 'artists')
		assert_equal lastfm_artists.length, hits.length, "Didn't return all hits"
		assert_equal lastfm_artists[0]['name'], hits[0][:name], "Didn't set name"
		assert_equal lastfm_artists[0]['listeners'].to_f,
		             hits[0][:popularity], "Didn't set popularity"
		assert_equal lastfm_artists[0]['image'][0]['#text'],
		             hits[0][:images][0][:url], "Didn't set image url"
	end
	
	test 'search for albums' do
		hits = Backend::Lastfm.search('foo', 'albums')
		assert_equal lastfm_albums.length, hits.length, "Didn't return all hits"
		assert_equal lastfm_albums[0]['name'], hits[0][:name], "Didn't set name"
		assert_equal lastfm_albums[0]['artist'], hits[0][:artist], "Didn't set artist"
		assert_equal lastfm_albums[0]['image'][0]['#text'],
		             hits[0][:images][0][:url], "Didn't set image url"
	end
	
	test 'search for songs' do
		hits = Backend::Lastfm.search('foo', 'songs')
		assert_equal lastfm_tracks.length, hits.length, "Didn't return all hits"
		assert_equal lastfm_tracks[0]['name'], hits[0][:name], "Didn't set name"
		assert_equal lastfm_tracks[0]['listeners'].to_f,
		             hits[0][:popularity], "Didn't set popularity"
		assert_equal lastfm_tracks[0]['artist'], hits[0][:artist], "Didn't set artist"
		assert_equal lastfm_tracks[0]['image'][0]['#text'],
		             hits[0][:images][0][:url], "Didn't set image url"
	end
	
	test 'search for events' do
		hits = Backend::Lastfm.search('foo', 'events')
		assert_equal lastfm_events.length, hits.length, "Didn't return all hits"
		assert_equal lastfm_events[0]['title'], hits[0][:name], "Didn't set name"
		assert_equal lastfm_events[0]['attandance'].to_f,
		             hits[0][:popularity], "Didn't set popularity"
		assert_equal lastfm_events[0]['artists']['artist'], hits[0][:artists], "Didn't set artists"
		assert_equal lastfm_events[0]['venue']['location']['geo:point']['geo:lat'].to_f,
		             hits[0][:location][:latitude], "Didn't set location"
		assert_equal lastfm_events[0]['venue']['location']['city'],
		             hits[0][:city], "Didn't set city"
		assert_equal lastfm_events[0]['image'][0]['#text'],
		             hits[0][:images][0][:url], "Didn't set image url"
	end
	
	test 'search for artists and albums' do
		hits = Backend::Lastfm.search('foo', 'artists|albums')
		assert_equal lastfm_artists.length + lastfm_albums.length, hits.length, "Didn't return all hits"
	end
	
	test 'get info for artist' do
		x = Backend::Lastfm.get_info('foo', 'artist')
		assert x, "Didn't return anything"
		assert_equal lastfm_artists[0]['name'], x[:name], "Didn't set name"
	end
	
	test 'get info for album' do
		x = Backend::Lastfm.get_info("foo\tfoo", 'album')
		assert x, "Didn't return anything"
		assert_equal lastfm_albums[0]['name'], x[:name], "Didn't set name"
	end
	
	test 'get info for song' do
		x = Backend::Lastfm.get_info("foo\tfoo", 'song')
		assert x, "Didn't return anything"
		assert_equal lastfm_tracks[0]['name'], x[:name], "Didn't set name"
	end
	
	test 'get info for event' do
		x = Backend::Lastfm.get_info('foo', 'event')
		assert x, "Didn't return anything"
		assert_equal lastfm_events[0]['title'], x[:name], "Didn't set name"
	end
	
	test 'get info for invalid artist' do
		x = Backend::Lastfm.get_info('bar', 'artist')
		assert !x, "Returned something"
	end
	
	test 'get info for invalid album' do
		x = Backend::Lastfm.get_info("bar\tfoo", 'album')
		assert !x, "Returned something"
	end
	
	test 'get info for invalid song' do
		x = Backend::Lastfm.get_info("bar\tfoo", 'song')
		assert !x, "Returned something"
	end
	
	test "get info for invalid song's artist" do
		x = Backend::Lastfm.get_info("bar\tbar", 'song')
		assert !x, "Returned something"
	end
	
	test 'get info for invalid event' do
		x = Backend::Lastfm.get_info('bar', 'event')
		assert !x, "Returned something"
	end
end
