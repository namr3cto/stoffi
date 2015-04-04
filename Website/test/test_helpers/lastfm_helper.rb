module Backend::Lastfm::TestHelpers
	
	def lastfm_artists
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
	end
	
	def lastfm_albums
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
	end
	
	def lastfm_tracks
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
	end
	
	def lastfm_events
		[
			{
				'id' => '123',
				'title' => 'The Monster Tour',
				'artists' =>
				{
					'artist' => ['Eminem', 'Rihanna'],
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
					'artist' => ['Eminem', 'John Mayer', 'B.o.B', 'Lorde'],
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
	end
	
	def stub_lastfm
		resources = ['artists', 'albums', 'tracks', 'events']
		search = {}
		info = {}
		invalid = {}
		
		# create structures
		resources.each do |r|
			search[r] = 
			{
				'results' =>
				{
					'opensearch:totalResults' => send("lastfm_#{r}").length.to_s,
					"#{r.singularize}matches" => { r.singularize => send("lastfm_#{r}") }
				}
			}
			info[r] = { r.singularize => send("lastfm_#{r}")[0] }
			invalid[r] = { 'error' => 6, 'message' => "#{r.singularize.capitalize} not found", 'links' => [] }
		end
		invalid['artists']['message'] = 'The artist you supplied could not be found'
		invalid['events']['message'] = 'Invalid event id supplied'
		
		# create stubs
		resources.each do |r|
			stub_request(:any, /.*ws.audioscrobbler.com.*method=#{r.singularize}\.search.*/).
				to_return(:body => search[r].to_json, :status => 200)
			stub_request(:any, /.*ws.audioscrobbler.com.*#{r.singularize}=foo.*method=#{r.singularize}\.getInfo.*/).
				to_return(:body => info[r].to_json, :status => 200)
			stub_request(:any, /.*ws.audioscrobbler.com.*#{r.singularize}=bar.*method=#{r.singularize}\.getInfo.*/).
				to_return(:body => invalid[r].to_json, :status => 200)
		end
		stub_request(:any, /.*ws.audioscrobbler.com.*artist=foo.*method=track\.getInfo.*track=foo.*/).
			to_return(:body => info['tracks'].to_json, :status => 200)
		stub_request(:any, /.*ws.audioscrobbler.com.*artist=foo.*method=track\.getInfo.*track=bar.*/).
			to_return(:body => invalid['tracks'].to_json, :status => 200)
		stub_request(:any, /.*ws.audioscrobbler.com.*artist=bar.*method=track\.getInfo.*track=bar.*/).
			to_return(:body => invalid['artists'].to_json, :status => 200)
	end
	
end