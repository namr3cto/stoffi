#
# Creates a listen.
# 
# Called whenever a listen is created and we need
# to show it in real time for any user who should
# be seeing it.
#
# @param object_params
#   The parameters of the object, encoded in JSON.
#
@createListen = (object_params) ->
	params = JSON.parse object_params
	song_id = params["song_id"]
	
	e = $("[data-template='song'] li:first").clone()
	e.hide()
	e.attr 'data-object', "song-#{song_id}"
	e.attr 'data-href', "/#{locale}/songs/#{song_id}"
	e.find("[data-field='title']").text params['title']
	e.find("[data-field='description']").text params['description']
	e.find("[data-field='picture']").attr 'src', params['picture']

	$("[data-list='listens'] li.item").first().before e
	
	list = $("[data-list='listens']")
	max = list.attr 'data-max-length'
	items = list.children 'li'
	
	$("[data-empty='listens']").slideUp()
	
	last = list.find 'li.item:last'
	
	console.log "max: #{max}"
	console.log "items: #{items.length}"
	console.log "last: #{last}"
	
	if max? && items.length > max && last?
		console.log 'remove last'
		last.slideUp 400, () ->
			last.remove()
			$("[data-object='song-#{song_id}']").slideDown()
	else
		console.log 'just add'
		$("[data-object='song-#{song_id}']").slideDown()
	e