require 'crawler/crawler.rb'

namespace :crawler do
	
	desc "Start the crawler"
	task start: :environment do
		begin
			c = Crawler.new
		rescue
			puts 'crawler already running'
		end
	end

	desc "Stop the crawler"
	task stop: :environment do
		Crawler.stop
	end
	
	desc 'Check the status of the crawler'
	task status: :environment do
		status = Crawler.status
		if status[:running]
			puts 'crawler is running'
			puts ''
			puts "  queries processed: #{status[:processed]}"
			puts "     total run time: #{status[:runtime]}"
			puts "   queries in queue: #{status[:queue]}"
			puts "      current query: #{status[:current_query]}"
		else
			puts 'no crawler is running'
		end
	end

end
