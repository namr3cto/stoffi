$ ->
	$('[data-add-to-resource]').on 'mousedown', (event) ->
		event.stopPropagation()
		alert 'add something to something'