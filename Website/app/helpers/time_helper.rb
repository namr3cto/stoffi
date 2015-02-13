module TimeHelper
	
	def seconds_to_duration(seconds)
		return '00:00' unless seconds
		
		t = Time.at(seconds).utc
		str = t.strftime('%M:%S')
		
		# hours
		if seconds >= 3600
			str = "#{t.strftime('%H')}:#{str}"
		end
		
		# days
		if seconds >= 3600*24
			str = "#{seconds / 3600*24}:#{str}"
		end
		
		str
	end
	
end