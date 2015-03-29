songClicked = (element, playlist) ->
	song = element.data 'resource-id'
	input = element.closest('#edit-playlist').find('form #query')
	input.focus()
	input.select()
	element.closest('#search-results').html('')
	addSongToPlaylist song, playlist

$(document).on 'contentReady', () ->
	$('#edit-playlist form').when 'submit.edit.playlist', ->
		$('#edit-playlist #search-results').html ''
		
	$('#edit-playlist #search-results .item').when 'click.edit.playlist', (event) ->
		p = $(@).closest('#edit-playlist').data 'playlist-id'
		songClicked $(@), p
		event.stopPropagation()
		
	$("[data-add-to-resource='playlist']").when 'click.addto.playlist', (event) ->
		if event.which == 1
			event.stopPropagation()
			playlist = $(@).data 'add-to-id'
			song = $(@).closest("[data-resource-type='song']").data 'resource-id'
			addSongToPlaylist song, playlist
			$(@).closest('.dropdown-menu').blur()