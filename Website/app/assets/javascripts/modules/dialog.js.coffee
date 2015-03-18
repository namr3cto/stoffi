isOpening = false

@closeDialog = () ->
	$('#dialog-overlay').fadeOut()

@openDialog = (url, callback) ->
	isOpening = true
	$('#dialog #content').hide()
	$('#dialog .alert').hide()
	$('#dialog .loading').show()
	
	$('#dialog-overlay').fadeIn (event) ->
		isOpening = false
		
	$.ajax {
		url: url,
		error: (jqXHR, status, error) ->
			$('#dialog .alert').html error
			$('#dialog .alert').show()
			$('#dialog .loading').hide()
		success: (data, status, jqXHR) ->
			$('#dialog .loading').hide()
			$('#dialog .alert').hide()
			$('#dialog #content').html data
			$('#dialog #content').show()
	}
	
$ ->
	$('body').on 'click', (event) ->
		if event.which == 1 and (
			event.target.id == '#dialog' or
			$(event.target).closest('#dialog').length)
			return
		if $('#dialog-overlay').is(':visible') and not isOpening
			closeDialog()