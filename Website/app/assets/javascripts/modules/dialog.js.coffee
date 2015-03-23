isOpening = false

@closeDialog = () ->
	$('#dialog-overlay').fadeOut()

@openDialog = (url, options) ->
	$.extend true, { mode: 'float' }, options
	if options['mode'] == 'inline' and not 'parent' in options
		$.error 'You must specify parent if you use inline dialog mode.'
		return
	isOpening = true
	$('#dialog-overlay').attr('data-dialog-mode', options['mode'])
	
	if options['mode'] == 'inline'
		p = $(options['parent'])
		$('#dialog-overlay').css 'width', p.width()
		$('#dialog-overlay').css 'height', p.height()
		$('#dialog-overlay').css 'top', p.offset().top
		$('#dialog-overlay').css 'left', p.offset().left
	else
		$('#dialog-overlay').removeAttr 'style'
	
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