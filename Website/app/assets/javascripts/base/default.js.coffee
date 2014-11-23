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
		
loadAjax = ->
	$('[data-fill] [data-loading]').load ->
		$(@)

jQuery ->
	hookHref()
	$(document).ajaxComplete -> hookHref()
	
	
hookHref = ->
	
	# these elements are like links; click and go somewhere!
	$('[data-href]').click ->
		window.location = $(@).data 'href'
		
	# these elements are resized so the smallest side is as
	# long as the value specified
	$('[data-square]').load ->
		resizeImage $(@), $(@).data('square')