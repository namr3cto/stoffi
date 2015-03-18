#
# Execute a command on a playlist.
# 
# Called whenever a command is executed on a playlist
# and we need to do some changes to playlists that users
# may be viewing.
#
# @param command
#   The command to be executed.
#
# @param params
#   The ID of the playlist.
#
@executePlaylist = (command, id) ->
	switch command
		when 'follow' then follow id
		when 'unfollow' then unfollow id
		
follow = (id) ->
	items = $("[data-resource-type='playlist'][data-resource-id='#{id}']")
	
	for button in items.find("[data-button='follow']")
		hide $(button)
		
	for button in items.find("[data-button='unfollow']")
		show $(button)
		
	$.ajax {
		url: "/playlists/#{id}.json",
		method: 'get',
		success: (data, status, jqXHR) ->
			insert data, "[data-list='playlists'][data-list-followings='#{user_id}']"
	}
		
unfollow = (id) ->
	items = $("[data-resource-type='playlist'][data-resource-id='#{id}']")
	
	for button in items.find("[data-button='follow']")
		show $(button)
		
	for button in items.find("[data-button='unfollow']")
		hide $(button)
		
	remove $("[data-list='playlists'][data-list-followings='#{user_id}']").find(
		"[data-resource-type='playlist'][data-resource-id='#{id}']"), 'fade'
	
@insert = (params, list) ->
	id = params["id"]
	e = $("[data-template='playlist'] li:first").clone()
	e.hide()
	e.attr 'data-resource-id', id
	e.attr 'data-href', "/#{locale}/playlists/#{id}"
	e.attr 'data-resource-url', "/#{locale}/playlists/#{id}"
	e.find("[data-field='name']").text params['name']
	e.find("[data-field='description']").text params['description']
	e.find("[data-field='picture']").attr 'src', params['picture']

	$(list).prepend e
	
	max = $(list).closest("[data-list='playlists']").attr 'data-max-length'
	items = $(list).children(".item:not([data-list-add])")
	
	$(list).children("[data-list-empty]").slideUp()
	
	last = $(list).children(".item:not([data-list-add])").last()
	object = "[data-resource-type='playlist'][data-resource-id='#{id}']"
	
	if max? && items.length > max && last?
		last.slideUp 400, () ->
			last.remove()
			$(object).slideDown()
	else
		$(object).slideDown()