module AppsHelper
	
	def prefixed_app_url(url)
		"#{request.protocol}#{request.host_with_port}#{url}"
	end
	
	# use this until we rename ClientApplication and OAuthClient to App
	def client_applications_path(*args); apps_path(*args) end
	
end