namespace :geoip do
	
	desc "Update the databases"
	task update: :environment do
		urls = [
			'/download/geoip/database/GeoLiteCountry/GeoIP.dat.gz',
			'/download/geoip/database/GeoLiteCity.dat.gz',
			'/download/geoip/database/asnum/GeoIPASNum.dat.gz'
		]
		Net::HTTP.start('geolite.maxmind.com') do |http|
			urls.each do |url|
				fname = File.basename(url, '.gz')
				resp = http.get(url)
				puts "downloaded #{fname}.gz"
				open(Rails.root.join('lib', 'assets', File.basename(url, '.gz')), "wb") do |file|
					file.write(ActiveSupport::Gzip.decompress(resp.body))
				end
				puts "decompressed #{fname}.gz"
			end
		end
		puts "geoip databases has been successfully updated"
		
	end
	
end