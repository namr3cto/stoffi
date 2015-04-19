module GeoipHelper
	
	def city_with_flag(ip)
		country = origin_country(ip)
		code = country.present? ? country.country_code2.to_s : ''
		flag = (code.blank? or code == '--') ? '' : image_tag("flags/#{code.downcase}.png", class: :flag)
		city = origin_city(ip)
		city = city.present? ? city.city_name : t('city.unknown')
		city = city.present? ? city : country(ip)
		(flag+content_tag(:span, city)).html_safe
	end
	
	def country(ip)
		country = origin_country(ip)
		code = country.present? ? country.country_code2.to_s : ''
		t((code.blank? or code == '--') ? 'unknown' : "countries.#{code}")
	end
	
	def network(ip)
		local_nets = ['10.0.0.0/8', '172.16.0.0/12', '192.168.0.0/16', '127.0.0.1']
		if local_nets.any? { |x| IPAddr.new(x) === ip }
			return t('local')
		end
		origin_network(ip).asn
	rescue
		t 'unknown'
	end
	
end