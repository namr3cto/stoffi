updateIcon = (size) ->
	default_url = "/assets/gfx/icons/#{size}/app.png"
	field = $("#client_application_icon_#{size}")
	icon = $("#icon_#{size}")
	console.log "check if #{size} is an image"
	$('<img/>', {
		src: field.val()
		error: ->
			icon.attr 'src', default_url
		load: ->
			icon.attr 'src', field.val()
	})


$(document).on 'contentReady', ->
	$('#client_application_icon_16').when 'change', ->
		updateIcon('16')
	$('#client_application_icon_64').when 'change', ->
		updateIcon('64')
	$('#client_application_icon_512').when 'change', ->
		updateIcon('512')
		
	updateIcon('16')
	updateIcon('64')
	updateIcon('512')