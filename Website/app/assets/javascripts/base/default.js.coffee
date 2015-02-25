resizeImage = (image, size) ->
	if image.height() > image.width()
		image.width size
	else
		image.height size
		
		# center image horizontally
		l = (image.width() - size) / 2
		r = size + l
		image.css 'clip', "rect(0px,#{r}px,#{size}px,#{l}px)"
		image.css 'margin-left', "-#{l}px"
	
	
initHooks = ->
	
	# these elements are like links; click and go somewhere!
	$('[data-href]').on 'mousedown', (event) ->
		if event.which == 1
			window.location = $(@).data 'href'
		
	# these elements are resized so the smallest side is as
	# long as the value specified
	$('[data-square]').load ->
		resizeImage $(@), $(@).data('square')
		
	# links which should remove a resource via ajax
	$("a[data-ajax-call='delete']").on 'click', (event) ->
		if event.which == 1
			event.stopPropagation()
			if not $(@).data('confirm') or confirm($(@).data('confirm'))
				resource_url = $(@).closest('[data-resource-url]').data('resource-url')+'.json'
				url = $(@).data('delete-url') || resource_url
				method = $(@).data('delete-method') || 'delete'
				data = $(@).data('delete-data') || ''
				item = $(@).closest('.item')
				item.hide 'fade', complete: () ->
					console.log 'send request'
					$.ajax {
						method: method,
						url: url,
						data: data,
						error: (output) ->
							console.log 'failure'
							console.log output
							item.show('fade')
						success: (output) ->
							console.log 'success'
							item.remove()
					}
		
jQuery ->
	
	# we want javascript links to not scroll or reload when clicked
	$("a[href='']").attr 'href', 'javascript:void(0)'
	$("a[href='#']").attr 'href', 'javascript:void(0)'
	
	# setup some hooks
	initHooks()
	$(document).ajaxComplete -> initHooks()