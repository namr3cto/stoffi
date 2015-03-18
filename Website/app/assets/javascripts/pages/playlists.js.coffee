$(document).on 'contentReady', () ->
	$('[data-add-to-resource]').when 'click.playlist.addto', (event) ->
		event.stopPropagation()
		event.preventDefault()
		alert 'add something to something'