#
# Add a song to an album.
#
# Calls PATCH on the album to update it,
# then retrieves the info on the song and
# inserts it into the DOM.
#
# @param song_id
#   The ID of the song to add.
#
# @param album_id
#   The ID of the album to add to.
#
addSongToAlbum = (song_id, album_id) ->	
	$.ajax {
		url: "/albums/#{album_id}.json",
		data: { songs: { added: [song_id] } },
		method: 'patch',
		success: ->	
			$.ajax {
				url: "/songs/#{song_id}.json",
				method: 'get',
				success: (data, status, jqXHR) ->
					insert 'song', data, "[data-list='songs'][data-list-album='#{album_id}']"
			}
	}

songClicked = (element, playlist) ->
	song = element.data 'resource-id'
	input = element.closest('#edit-album').find('form #query')
	input.focus()
	input.select()
	element.closest('#search-results').html('')
	addSongToAlbum song, playlist

$(document).on 'contentReady', () ->
	$('#edit-album form').when 'submit.edit.album', ->
		$('#edit-album #search-results').html ''
		
	$('#edit-album #search-results .item').when 'click.edit.album', (event) ->
		p = $(@).closest('#edit-album').data 'album-id'
		songClicked $(@), p
		event.stopPropagation()