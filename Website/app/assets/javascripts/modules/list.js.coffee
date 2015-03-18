$(document).on 'contentReady', () ->
	
	# problem:
	# we have an overlay which is shown on hover, but there is no hover on touch
	# they will however show the hover on a tap, but we also have data-href which\
	# means the item is also a link, so a tap or click should navigate away
	# 
	# solution:
	# trap the first tap on the item, and prevent us from navigating away
	# allow the second tap to propagate unless it is on the overlay
	#$('.sitem').on 'tap', (event) ->
	#	tapped = $(@).data 'tapped'
	#	
	#	unless tapped
	#		event.preventDefault()
	#		$(@).data 'tapped', true
		
		
	$('.item .action-bar span').when 'mousedown.list.actionbar', (event) ->
		event.stopPropagation()
		event.preventDefault()
		
	$('[data-list-add]').when 'click.list.add', (event) ->
		if event.which == 1
			openDialog $(@).data('list-add')
	
	# remove the 'empty' from all lists with items
	for l in $('[data-list]')
		if $(l).children('.item:not([data-list-add])').length > 0
			$(l).children('[data-list-empty]').hide()