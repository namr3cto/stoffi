namespace :services do
	
	desc "Start all services"
	task start: :environment do
		puts "starting solr"
		Rake::Task['sunspot:solr:start'].execute rescue nil
		
		puts 'starting redis'
		system('redis-server /usr/local/etc/redis.conf')
		
		port = Rails.env == :production ? 8443 : 8080
		puts "starting juggernaut on port #{port}"
		system("juggernaut --port #{port} 2>&1 > /var/log/juggernaut.log &")
	end

	desc "Stop all services"
	task stop: :environment do
		puts "stopping solr"
		Rake::Task['sunspot:solr:start'].execute
	end

	desc "Restart all services"
	task restart: [:stop, :start]

	desc "TODO"
	task status: :environment do
	end

end
