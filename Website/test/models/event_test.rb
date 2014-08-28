require 'test_helper'

class EventTest < ActiveSupport::TestCase
	
	test "should create event" do
		e = nil
		hash = {
			name: 'Foo',
			popularity: '123',
			category: 'festival',
			artists: ['Eminem', 'Bob Marley'],
			location: { longitude: 15, latitude: 15 },
			city: 'Something',
			id: '123',
			source: :lastfm,
			images: [
				{ url: 'http://foo.com/img1.jpg' },
				{ url: 'http://foo.com/img2.jpg' },
			],
			type: :event,
			url: 'http://foo.org/',
			start_date: 2.days.from_now
		}
		assert_difference 'Event.count', 1, "Didn't create new event" do
			e = Event.find_or_create_by_hash(hash)
		end
		assert e, "Didn't return event"
		assert_equal hash[:name], e.name, "Didn't set name"
		assert_equal hash[:city], e.venue, "Didn't set city"
		assert_equal hash[:start_date], e.start, "Didn't set start date"
		assert_equal hash[:location][:longitude], e.longitude, "Didn't set location"
		
		assert_equal hash[:artists].length, e.artists.count, "Didn't set artists"
		assert_equal hash[:images].length, e.images.count, "Didn't set images"
		assert_equal 1, e.sources.count, "Didn't set source"
		
		s = e.sources[0]
		
		assert_equal hash[:popularity].to_f, s.popularity, "Didn't set source popularity"
		assert_equal hash[:id], s.foreign_id, "Didn't set source id"
		assert_equal hash[:url], s.foreign_url, "Didn't set source url"
		assert_equal hash[:source], s.name, "Didn't set source name"
	end
	
	test "should find event" do
		e = events(:concert2)
		hash = {
			name: e.name,
			location: { longitude: e.longitude, latitude: e.latitude },
			city: e.venue,
			popularity: '123',
			id: '123',
			source: :lastfm,
			images: [
				{ url: 'http://foo.com/img1.jpg' },
				{ url: 'http://foo.com/img2.jpg' },
			],
			url: 'http://foo.org/',
			start_date: e.start,
			end_date: e.stop
		}
		event = nil
		assert_no_difference 'Event.count', "Created new event" do
			event = Event.find_or_create_by_hash(hash)
		end
		assert_equal e, event, "Didn't return correct event"
		
		s = e.sources.where(name: :lastfm).first
		assert s, "Didn't set source"
		assert_equal hash[:popularity].to_f, s.popularity, "Didn't set source popularity"
		assert_equal hash[:id], s.foreign_id, "Didn't set source id"
		assert_equal hash[:url], s.foreign_url, "Didn't set source url"
		assert_equal hash[:source].to_s, s.name, "Didn't set source name"
	end
	
	test "should get top events" do
		e = Event.top.limit(3)
		assert_equal 3, e.length, "Didn't return three top events"
		assert e[0].listens.count == e[1].listens.count, "Top events not in order (first and second, listens)"
		assert e[0].popularity    >= e[1].popularity, "Top events not in order (first and second, popularity)"
		assert e[1].listens.count >= e[2].listens.count, "Top events not in order (second and third)"
	end
end
