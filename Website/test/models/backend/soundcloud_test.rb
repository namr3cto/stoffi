require 'test_helper'

class YoutubeTest < ActiveSupport::TestCase
	def setup
		@tracks = [
			{
				'kind' => 'track',
				'id' => 123,
				'duration' => 427611,
				'genre' => '',
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
			to_return(:body => @tracks.to_json, :status => 200)
		stub_request(:any, /https:\/\/api.soundcloud.com\/tracks\/123\.json.*/).
			to_return(:body => @tracks[0].to_json, :status => 200)
		stub_request(:any, /https:\/\/api.soundcloud.com\/tracks\/321\.json.*/).
			to_return(:body => @tracks[1].to_json, :status => 200)
		stub_request(:any, /https:\/\/api.soundcloud.com\/tracks\/456\.json.*/).
			to_return(:body => @tracks[2].to_json, :status => 200)
		super
	end
	
	test 'should get songs' do
		songs = Backend::Soundcloud.get_songs(['123', '456'])
		assert_equal 2, songs.count, "Didn't get the correct number of songs"
		assert_equal @tracks[2]['playback_count'], songs[1][:popularity], "Didn't get the correct popularity"
		assert_equal @tracks[2]['duration']/1000.0, songs[1][:length], "Didn't get the correct length"
	end
end
