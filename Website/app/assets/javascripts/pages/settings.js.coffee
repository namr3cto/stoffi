refreshCustomNameVisibility = ->
	if $('#user_name_source').children(':selected').val() == ''
		$('#user_custom_name').show()
	else
		$('#user_custom_name').hide()

refreshPasswordFieldVisibility = ->
	if $('#edit_password').is ':checked'
		$('#edit_password_fields').show()
	else
		$('#edit_password_fields').hide()
		
linkCheckboxClicked = (element) ->
	isChecked = element.is(':checked')
	data = "link[do_#{element.data('account-setting')}]=#{isChecked}"
	
	# NOTE: hardcoded link path
	url = "/links/#{element.data('account-id')}.json"
	
	$.ajax {
		url: url,
		type: 'PUT',
		data: data,
		error: (jqXHR) ->
			if jqXHR.status != 200
				element.prop('checked', !isChecked)
	}

$(document).on 'contentReady', () ->
	refreshCustomNameVisibility()
	$('#user_name_source').when 'change.settings.name', (event) ->
		stopPropagation()
		refreshCustomNameVisibility()
		
	if $('#user_name_source option').length == 1
		$('#user_name_source').hide()
		$('#user_custom_name').removeClass 'short'
		
	refreshPasswordFieldVisibility()
	$('#edit_password').when 'click.settings.passwd', (event) ->
		stopPropagation()
		refreshPasswordFieldVisibility()
		
	$('input[type=checkbox][data-account-setting]').when 'click.settings.check', (event) ->
		stopPropagation()
		linkCheckboxClicked $(this)
		