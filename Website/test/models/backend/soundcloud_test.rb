require 'test_helper'

class YoutubeTest < ActiveSupport::TestCase
	def setup
		@songs = [
			{
				'kind' => 'track',
				'id' => 123,
				'duration' => 427611,
				'genre' => '',
				'title' => 'bob marley-one love',
				'permalink_url' => 'https://example.com/123',
				'artwork_url' => 'https://example.com/123.jpg',
				'stream_url' => 'https://example.com/123/stream',
				'playback_count' => 321,
				'user' => {
					'username' => 'User 1'
				}
			},
			{
				'kind' => 'track',
				'id' => 321,
				'duration' => 327611,
				'genre' => 'reggae',
				'title' => 'Bob Marley - Jamming',
				'permalink_url' => 'https://example.com/321',
				'artwork_url' => 'https://example.com/321.jpg',
				'stream_url' => 'https://example.com/321/stream',
				'playback_count' => 123,
				'user' => {
					'username' => 'User 2'
				}
			},
			{
				'kind' => 'track',
				'id' => 456,
				'duration' => 527611,
				'genre' => 'Reggae, Reggaeton',
				'title' => 'Bob Marley & The Wailers "Buffalo Solider"',
				'permalink_url' => 'https://example.com/456',
				'artwork_url' => 'https://example.com/456.jpg',
				'stream_url' => 'https://example.com/456/stream',
				'playback_count' => 654,
				'user' => {
					'username' => 'User 1'
				}
			},
		]
		stub_request(:any, /https:\/\/api.soundcloud.com\/tracks\.json.*q=.*/).
			to_return(:body => @songs.to_json, :status => 200)
		stub_request(:any, /https:\/\/api.soundcloud.com\/tracks\/123\.json.*/).
			to_return(:body => @songs[0].to_json, :status => 200)
		stub_request(:any, /https:\/\/api.soundcloud.com\/tracks\/321\.json.*/).
			to_return(:body => @songs[1].to_json, :status => 200)
		stub_request(:any, /https:\/\/api.soundcloud.com\/tracks\/456\.json.*/).
			to_return(:body => @songs[2].to_json, :status => 200)
		super
	end
	
	test 'should get songs' do
		songs = Backend::Soundcloud.get_songs(['123', '456'])
		assert_equal 2, songs.count, "Didn't get the correct number of songs"
		assert_equal @songs[2]['playback_count'], songs[1][:popularity], "Didn't get the correct popularity"
		assert_equal @songs[2]['duration']/1000.0, songs[1][:length], "Didn't get the correct length"
	end
	
	test 'search for songs' do
		hits = Backend::Soundcloud.search('foo', 'songs')
		assert_equal @songs.length, hits.length, "Didn't return all hits"
		assert_equal @songs[0]['title'], hits[0][:name], "Didn't set name"
		assert_equal @songs[0]['playback_count'].to_f, hits[0][:popularity], "Didn't set popularity"
		assert_equal @songs[0]['artwork_url'], hits[0][:images][0][:url], "Didn't set image url"
	end
end
