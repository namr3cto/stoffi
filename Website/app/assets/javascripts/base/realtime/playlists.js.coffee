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
		
#
# Updates a playlist.
# 
# Called whenever a playlist is modified and we need
# to adjust what the user may be viewing.
#
# @param id
#   The ID of the playlist object.
#
# @param updated_params
#   The parameters that were changed, encoded in JSON.
#	
@updatePlaylist = (id, updated_params) ->
	params = JSON.parse updated_params
	
	if 'is_public' of params
		resource = $("[data-resource-type='playlist'][data-resource-id='#{id}']")
		checkbox = resource.find("[data-field='public']")
		checkbox.prop('checked', params['is_public'])
	
	# add/remove songs
	return unless 'songs' of params
	
	list = "[data-list='songs'][data-list-playlist='#{id}']"
	
	if 'added' of params['songs']
		for song in params['songs']['added']
			insert 'song', song, list
		
	if 'removed' of params['songs']
		for song in params['songs']['removed']
			song_id = song['id']
			element = $(list).find("[data-resource-type='song'][data-resource-id='#{song_id}']")
			element.hide 'fade', ->
				element.remove()
		
#
# Add a song to a playlist.
#
# Calls PUT on the playlist to update it,
# then retrieves the info on the song and
# inserts it into the DOM.
#
# @param song_id
#   The ID of the song to add.
#
# @param playlist_id
#   The ID of the playlist to add to.
#
@addSongToPlaylist = (song_id, playlist_id) ->	
	$.ajax {
		url: "/playlists/#{playlist_id}.json",
		data: { songs: { added: [song_id] } },
		method: 'put',
		success: ->	
			$.ajax {
				url: "/songs/#{song_id}.json",
				method: 'get',
				success: (data, status, jqXHR) ->
					insert 'song', data, "[data-list='songs'][data-list-playlist='#{playlist_id}']"
			}
	}
	
		
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
			insert 'playlist', data, "[data-list='playlists'][data-list-followings='#{user_id}']"
	}
		
unfollow = (id) ->
	items = $("[data-resource-type='playlist'][data-resource-id='#{id}']")
	
	for button in items.find("[data-button='follow']")
		show $(button)
		
	for button in items.find("[data-button='unfollow']")
		hide $(button)
		
	remove $("[data-list='playlists'][data-list-followings='#{user_id}']").find(
		"[data-resource-type='playlist'][data-resource-id='#{id}']"), 'fade'
	
@insert = (resource, params, list) ->
	resources = resource.pluralize()
	id = params["id"]
	e = $("[data-template='#{resource}'] li:first").clone()
	e.hide()
	e.attr 'data-resource-id', id
	e.attr 'data-href', "/#{locale}/#{resources}/#{id}"
	e.attr 'data-resource-url', "/#{locale}/#{resources}/#{id}"
	e.find("[data-field='display']").text params['display']
	e.find("[data-field='subtitle']").text params['subtitle']
	e.find("[data-field='picture']").attr 'src', params['image']

	$(list).prepend e
	
	max = $(list).closest("[data-list='#{resources}']").attr 'data-max-length'
	items = $(list).children(".item:not([data-list-add])")
	
	$(list).children("[data-list-empty]").slideUp()
	
	last = $(list).children(".item:not([data-list-add])").last()
	object = "[data-resource-type='#{resource}'][data-resource-id='#{id}']"
	
	if max? && items.length > max && last?
		last.slideUp 400, () ->
			last.remove()
			$(object).slideDown()
	else
		$(object).slideDown()