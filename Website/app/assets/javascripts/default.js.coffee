jQuery ->
	hookHref()
	$(document).ajaxComplete -> hookHref()
	
hookHref = ->
	$('[data-href]').click ->
		window.location = $(@).data('href')