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

jQuery ->
	refreshCustomNameVisibility()
	$('#user_name_source').on 'change', (event) ->
		refreshCustomNameVisibility()
		
	if $('#user_name_source option').length == 1
		$('#user_name_source').hide()
		$('#user_custom_name').removeClass 'short'
		
	refreshPasswordFieldVisibility()
	$('#edit_password').on 'click', (event) ->
		refreshPasswordFieldVisibility()
		
	$('input[type=checkbox][data-account-setting]').on 'click', (event) ->
		linkCheckboxClicked $(this)
		