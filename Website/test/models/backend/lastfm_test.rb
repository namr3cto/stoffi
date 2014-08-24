require 'test_helper'

class LastfmTest < ActiveSupport::TestCase
	def setup
		@artists = 
		[
			{
				'name' => 'Bob Marley',
				'listeners' => '123',
				'url' => 'http://foo.com/artist/bob_marley',
				'image' => [
					{ '#text' => 'http://bob/s.jpg', 'size' => 'small' },
					{ '#text' => 'http://bob/m.jpg', 'size' => 'medium' },
					{ '#text' => 'http://bob/l.jpg', 'size' => 'large' },
				]
			},
			{
				'name' => 'Damian Marley',
				'listeners' => '12',
				'url' => 'http://foo.com/artist/damian_marley',
				'image' => [
					{ '#text' => 'http://damian/s.jpg', 'size' => 'small' },
					{ '#text' => 'http://damian/m.jpg', 'size' => 'medium' },
					{ '#text' => 'http://damian/l.jpg', 'size' => 'large' },
				]
			},
			{
				'name' => 'Stephen Marley',
				'listeners' => '23',
				'url' => 'http://foo.com/artist/stephen_marley',
				'image' => [
					{ '#text' => 'http://stephen/s.jpg', 'size' => 'small' },
					{ '#text' => 'http://stephen/m.jpg', 'size' => 'medium' },
					{ '#text' => 'http://stephen/l.jpg', 'size' => 'large' },
				]
			}
		]
		@albums = 
		[
			{
				'name' => 'Relapse',
				'artist' => 'Eminem',
				'id' => '123',
				'url' => 'http://foo.com/album/relapse',
				'image' => [
					{ '#text' => 'http://relapse/s.jpg', 'size' => 'small' },
					{ '#text' => 'http://relapse/m.jpg', 'size' => 'medium' },
					{ '#text' => 'http://relapse/l.jpg', 'size' => 'large' },
				]
			},
			{
				'name' => 'Relapse',
				'artist' => 'Chiasm',
				'id' => '321',
				'url' => 'http://foo.com/album/relapse2',
				'image' => [
					{ '#text' => 'http://relapse2/s.jpg', 'size' => 'small' },
					{ '#text' => 'http://relapse2/l.jpg', 'size' => 'large' },
				]
			}
		]
		@songs =
		[
			{
				'name' => 'The Last Relapse',
				'artist' => 'All Shall Perish',
				'url' => 'http://foo.com/track/last_relapse',
				'listeners' => '41640',
				'image' => [
					{ '#text' => 'http://last_relapse/l.jpg', 'size' => 'large' }
				]
			},
			{
				'name' => "I'm Having a Relapse",
				'artist' => 'Eminem',
				'url' => 'http://foo.com/track/having_relapse',
				'listeners' => '41640',
				'image' => [
					{ '#text' => 'http://having_relapse/l.jpg', 'size' => 'large' }
				]
			},
			{
				'name' => "Relapse",
				'artist' => 'Antimatter',
				'url' => 'http://foo.com/track/relapse',
				'listeners' => '28445',
				'image' => [
					{ '#text' => 'http://anti_relapse/s.jpg', 'size' => 'small' }
				]
			}
		]
		@events =
		[
			{
				'id' => '123',
				'title' => 'The Monster Tour',
				'artists' =>
				{
					'artist' => ['Eminem', 'Rihanna' ],
					'headliner' => 'Eminem'
				},
				'venue' =>
				{
					'id' => '123',
					'name' => 'MetLife Stadium',
					'location' =>
					{
						'geo:point' =>
						{
							'geo:lat' => '40.814209',
							'geo:long' => '-74.07369'
						},
						'city' => 'East Rutherford, NJ',
						'country' => 'United States',
						'street' => '1 MetLife Stadium Dr',
						'postalcode' => '07073'
					},
					'url' => 'http://foo.com/venue/metlife',
					'website' => 'http://metlifestadium.com',
					'image' =>
					[
						{ '#text' => 'http://metlife/m.jpg', 'size' => 'medium' }
					]
				},
				'startDate' => 2.days.from_now,
				'description' => '',
				'image' =>
				[
					{ '#text' => 'http://monster/l.jpg', 'size' => 'large' },
					{ '#text' => 'http://monster/xl.jpg', 'size' => 'extralarge' },
				],
				'attendence' => '15',
				'url' => 'http://foo.com/event/monster'
			},
			{
				'id' => '321',
				'title' => 'Music Midtown',
				'artists' =>
				{
					'artist' => ['Eminem', 'John Mayer', 'B.o.B', 'Lorde' ],
					'headliner' => 'Eminem'
				},
				'venue' =>
				{
					'id' => '321',
					'name' => 'Piedmont Park',
					'location' =>
					{
						'geo:point' =>
						{
							'geo:lat' => '33.784241',
							'geo:long' => '-84.363975'
						},
						'city' => 'Atlanta',
						'country' => 'United States',
						'street' => '400 Park Drive',
						'postalcode' => '30306'
					},
					'url' => 'http://foo.com/venue/piedmont',
					'website' => '',
					'image' =>
					[
						{ '#text' => '', 'size' => 'small' },
						{ '#text' => '', 'size' => 'medium' },
					]
				},
				'startDate' => 3.days.from_now,
				'endDate' => 4.days.from_now,
				'description' => '',
				'image' =>
				[
					{ '#text' => 'http://piedmont/s.jpg', 'size' => 'small' },
					{ '#text' => 'http://piedmont/l.jpg', 'size' => 'large' },
				],
				'attendence' => '26',
				'url' => 'http://foo.com/event/piedtown',
				'website' => 'http://www.musicmidtown.com'
			},
		]
		
		@artist_search = 
		{
			'results' =>
			{
				'opensearch:totalResults' => @artists.length.to_s,
				'artistmatches' => { 'artist' => @artists }
			}
		}
		@album_search = 
		{
			'results' =>
			{
				'opensearch:totalResults' => @albums.length.to_s,
				'albummatches' => { 'album' => @albums }
			}
		}
		@song_search = 
		{
			'results' =>
			{
				'opensearch:totalResults' => @songs.length.to_s,
				'trackmatches' => { 'track' => @songs }
			}
		}
		@event_search = 
		{
			'results' =>
			{
				'opensearch:totalResults' => @events.length.to_s,
				'eventmatches' => { 'event' => @events }
			}
		}
		@artist_info = { 'artist' => @artists[0] }
		@album_info = { 'album' => @albums[0] }
		@song_info = { 'track' => @songs[0] }
		@event_info = { 'event' => @events[0] }
		
		@artist_invalid = { 'error' => 6, 'message' => 'The artist you supplied could not be found', 'links' => [] }
		@album_invalid = { 'error' => 6, 'message' => 'Album not found', 'links' => [] }
		@song_invalid = { 'error' => 6, 'message' => 'Track not found', 'links' => [] }
		@song_invalid_artist = { 'error' => 6, 'message' => 'Artist not found', 'links' => [] }
		@event_invalid = { 'error' => 6, 'message' => 'Invalid event id supplied', 'links' => [] }
		
		stub_request(:any, /.*ws.audioscrobbler.com.*method=artist\.search.*/).
			to_return(:body => @artist_search.to_json, :status => 200)
		stub_request(:any, /.*ws.audioscrobbler.com.*method=album\.search.*/).
			to_return(:body => @album_search.to_json, :status => 200)
		stub_request(:any, /.*ws.audioscrobbler.com.*method=track\.search.*/).
			to_return(:body => @song_search.to_json, :status => 200)
		stub_request(:any, /.*ws.audioscrobbler.com.*method=event\.search.*/).
			to_return(:body => @event_search.to_json, :status => 200)
			
		stub_request(:any, /.*ws.audioscrobbler.com.*artist=foo.*method=artist\.getInfo.*/).
			to_return(:body => @artist_info.to_json, :status => 200)
		stub_request(:any, /.*ws.audioscrobbler.com.*album=foo.*method=album\.getInfo.*/).
			to_return(:body => @album_info.to_json, :status => 200)
		stub_request(:any, /.*ws.audioscrobbler.com.*artist=foo.*method=track\.getInfo.*track=foo.*/).
			to_return(:body => @song_info.to_json, :status => 200)
		stub_request(:any, /.*ws.audioscrobbler.com.*event=foo.*method=event\.getInfo.*/).
			to_return(:body => @event_info.to_json, :status => 200)
			
		stub_request(:any, /.*ws.audioscrobbler.com.*artist=bar.*method=artist\.getInfo.*/).
			to_return(:body => @artist_invalid.to_json, :status => 200)
		stub_request(:any, /.*ws.audioscrobbler.com.*album=bar.*method=album\.getInfo.*/).
			to_return(:body => @album_invalid.to_json, :status => 200)
		stub_request(:any, /.*ws.audioscrobbler.com.*artist=foo.*method=track\.getInfo.*track=bar.*/).
			to_return(:body => @song_invalid.to_json, :status => 200)
		stub_request(:any, /.*ws.audioscrobbler.com.*artist=bar.*method=track\.getInfo.*track=bar.*/).
			to_return(:body => @song_invalid_artist.to_json, :status => 200)
		stub_request(:any, /.*ws.audioscrobbler.com.*event=bar.*method=event\.getInfo.*/).
			to_return(:body => @event_invalid.to_json, :status => 200)
		super
	end
	
	test 'search for artists' do
		hits = Backend::Lastfm.search('foo', 'artists')
		assert_equal @artists.length, hits.length, "Didn't return all hits"
		assert_equal @artists[0]['name'], hits[0][:name], "Didn't set name"
		assert_equal @artists[0]['listeners'].to_f,
		             hits[0][:popularity], "Didn't set popularity"
		assert_equal @artists[0]['image'][0]['#text'],
		             hits[0][:images][0][:url], "Didn't set image url"
	end
	
	test 'search for albums' do
		hits = Backend::Lastfm.search('foo', 'albums')
		assert_equal @albums.length, hits.length, "Didn't return all hits"
		assert_equal @albums[0]['name'], hits[0][:name], "Didn't set name"
		assert_equal @albums[0]['artist'], hits[0][:artist], "Didn't set artist"
		assert_equal @albums[0]['image'][0]['#text'],
		             hits[0][:images][0][:url], "Didn't set image url"
	end
	
	test 'search for songs' do
		hits = Backend::Lastfm.search('foo', 'songs')
		assert_equal @songs.length, hits.length, "Didn't return all hits"
		assert_equal @songs[0]['name'], hits[0][:name], "Didn't set name"
		assert_equal @songs[0]['listeners'].to_f,
		             hits[0][:popularity], "Didn't set popularity"
		assert_equal @songs[0]['artist'], hits[0][:artist], "Didn't set artist"
		assert_equal @songs[0]['image'][0]['#text'],
		             hits[0][:images][0][:url], "Didn't set image url"
	end
	
	test 'search for events' do
		hits = Backend::Lastfm.search('foo', 'events')
		assert_equal @events.length, hits.length, "Didn't return all hits"
		assert_equal @events[0]['title'], hits[0][:name], "Didn't set name"
		assert_equal @events[0]['attandance'].to_f,
		             hits[0][:popularity], "Didn't set popularity"
		assert_equal @events[0]['artists']['artist'], hits[0][:artists], "Didn't set artists"
		assert_equal @events[0]['venue']['location']['geo:point']['geo:lat'].to_f,
		             hits[0][:location][:latitude], "Didn't set location"
		assert_equal @events[0]['venue']['location']['city'],
		             hits[0][:city], "Didn't set city"
		assert_equal @events[0]['image'][0]['#text'],
		             hits[0][:images][0][:url], "Didn't set image url"
	end
	
	test 'search for artists and albums' do
		hits = Backend::Lastfm.search('foo', 'artists|albums')
		assert_equal @artists.length + @albums.length, hits.length, "Didn't return all hits"
	end
	
	test 'get info for artist' do
		x = Backend::Lastfm.get_info('foo', 'artist')
		assert x, "Didn't return anything"
		assert_equal @artists[0]['name'], x[:name], "Didn't set name"
	end
	
	test 'get info for album' do
		x = Backend::Lastfm.get_info("foo\tfoo", 'album')
		assert x, "Didn't return anything"
		assert_equal @albums[0]['name'], x[:name], "Didn't set name"
	end
	
	test 'get info for song' do
		x = Backend::Lastfm.get_info("foo\tfoo", 'song')
		assert x, "Didn't return anything"
		assert_equal @songs[0]['name'], x[:name], "Didn't set name"
	end
	
	test 'get info for event' do
		x = Backend::Lastfm.get_info('foo', 'event')
		assert x, "Didn't return anything"
		assert_equal @events[0]['title'], x[:name], "Didn't set name"
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
