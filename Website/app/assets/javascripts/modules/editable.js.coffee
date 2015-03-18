
#
# Activate an editable field.
#
# Turns the text into a changable input field.
#
activateEditable = (element) ->
	element.addClass 'active'
	element.children("input[type='text']").prop 'disabled', false
	element.children("input[type='text']").focus()
	element.data 'original', element.children("input[type='text']").val()
	
#
# Deactivate an editable field.
#
# Turns the input field into a static text.
#
deactivateEditable = (element) ->
	hasText = element.children('.text').length > 0
	element.removeClass 'active'
	element.children("input[type='text']").prop 'disabled', !hasText
	element.children("input[type='text']").val element.data('original')
	
	# fire keydown to trigger autosize
	element.children("input[type='text']").trigger jQuery.Event('keydown', { which: $.ui.keyCode.LEFT })
	
#
# Submit an editable field via AJAX.
#
submitEditable = (element) ->
	url = element.attr('data-editable-url')+'.json'
	method = element.attr 'data-editable-method'
	resource = element.attr 'data-editable-resource'
	field = element.children("input[type='text']").attr 'name'
	value = element.children("input[type='text']").val()
	original = element.data 'original'
	data = {}
	data[field] = value
	
	element.children("input[type='text']").val(value)
	element.find(".value").html(value)
	element.data 'original', value
	
	$.ajax {
		type: method,
		url: url,
		data: data,
		error: (output) ->
			element.children("input[type='text']").val(original)
			element.find(".value").html(original)
			element.data 'original', original
			deactivateEditable element
	}
	
	deactivateEditable element

$(document).on 'contentReady', () ->
	$('.editable').when 'click.editable', (event) ->
		unless $(@).hasClass 'disabled'
			activateEditable $(@)
		
	$(".editable input[type='text']").when 'keyup.editable', (event) ->
		if pressedEnter event
			submitEditable $(@).parent('.editable')
			
		else if pressedEscape event
			deactivateEditable $(@).parent('.editable')
		
	$(".editable input[type='text']").when 'blur.editable', (event) ->
		deactivateEditable $(@).parent('.editable')