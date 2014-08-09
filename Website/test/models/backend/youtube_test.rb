require 'test_helper'

class YoutubeTest < ActiveSupport::TestCase
	def setup
		@search = 
		{
			'items' => [
				{ 'id' => { 'videoId' => 'id1' } },
				{ 'id' => { 'videoId' => 'id2' } },
				{ 'id' => { 'videoId' => 'id3' } },
				{ 'id' => { 'videoId' => 'id4' } },
				{ 'id' => { 'videoId' => 'id5' } }
			]
		}.to_json
		@videos = {
			'items' => [
				{
					'id' => 'id1',
					'snippet' => {
						'title' => 'Bob Marley No Woman no cry',
						'thumbnails' => {
							'default' => {
								'url' => 'https://default1.jpg',
								'width' => 120,
								'height' => 90
							},
							'medium' => {
								'url' => 'https://medium1.jpg',
								'width' => 320,
								'height' => 180
							}
						}
					},
					'contentDetails' => { 'duration' => 'PT7M9S' },
					'statistics' => { 'viewCount' => '20882668' }
				},
				{
					'id' => 'id2',
					'snippet' => {
						'title' => 'Bob marley "no woman no cry" 1979',
						'thumbnails' => {
							'default' => {
								'url' => 'https://default2.jpg',
								'width' => 120,
								'height' => 90
							},
							'medium' => {
								'url' => 'https://medium2.jpg',
								'width' => 320,
								'height' => 180
							}
						}
					},
					'contentDetails' => { 'duration' => 'PT7M20S' },
					'statistics' => { 'viewCount' => '60107360' }
				},
			]
		}
		stub_request(:any, /https:\/\/www.googleapis.com\/youtube\/v3\/search.*/).
			to_return(:body => @search.to_json, :status => 200)
		stub_request(:any, /https:\/\/www.googleapis.com\/youtube\/v3\/videos.*/).
			to_return(:body => @videos.to_json, :status => 200)
	end
	
	test 'should get songs' do
		songs = Backend::Youtube.get_songs(['id1', 'id2'])
		assert_equal @videos['items'].count, songs.count, "Didn't get the correct number of songs"
		assert_equal 60107360, songs[1][:popularity], "Didn't get the correct popularity"
		assert_equal 7*60+20, songs[1][:length], "Didn't get the correct length"
	end
end
