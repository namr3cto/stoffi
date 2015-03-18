refreshDuplicate = (element) ->
	if element.attr('data-duplicate-status') == 'marked'
		element.find('[data-duplicate-mark]').hide()
		element.find('[data-duplicate-unmark]').show()
	else
		element.find('[data-duplicate-mark]').show()
		element.find('[data-duplicate-unmark]').hide()

toggleDuplicate = (element, event) ->
	url = element.closest('[data-resource-url]').attr('data-resource-url')
	archetype = element.attr 'data-archetype'
	status = element.attr 'data-duplicate-status'
	archetype = '' if status == 'marked'
	
	if status == 'marked'
		element.attr 'data-duplicate-status', 'unmarked'
	else
		element.attr 'data-duplicate-status', 'marked'
	refreshDuplicate element
	
	$.ajax {
		type: 'patch',
		url: url,
		data: "song[archetype]=#{archetype}",
		error: (output) ->
			element.attr 'data-duplicate-status', status
			refreshDuplicate element
	}

$(document).on 'contentReady', () ->
	for element in $("a[data-ajax-call='duplicate']")
		refreshDuplicate $(element)
	$("a[data-ajax-call='duplicate']").when 'click.duplicate', (event) ->
		if event.which == 1
			stopPropagation()
			preventDefault()
			toggleDuplicate($(@), event)