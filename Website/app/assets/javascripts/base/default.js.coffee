@show = (element, options) ->
	element.removeAttr 'data-hide'
	element.show options

@hide = (element, options) ->
	element.attr 'data-hide', true
	element.hide options
		
@remove = (element, options) ->
	options = {effect: options} if typeof(options) == "string"
	hide element, $.extend(options, complete: () ->
		list = element.closest('[data-list]')
		element.remove()
		if list.children('.item:not([data-list-add])').length == 0
			list.find('[data-list-empty]').slideDown()
	)
	
@getResource = (type, id) ->
	"[data-resource-type='#{type}'][data-resource-id='#{id}']"
	
$.fn.when = (types, selector, data, fn) ->
	this.off(types).on(types, selector, data, fn)

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
		
deleteClicked = (element, event) ->
	# TODO: move to list?
	resource_url = element.closest('[data-resource-url]').data('resource-url')+'.json'
	url = element.data('ajax-url') || resource_url
	method = element.data('ajax-method') || 'delete'
	data = element.data('ajax-data') || ''
	item = element.closest('.item')
	list = element.closest('[data-list]')
	
	item.hide 'fade', complete: () ->
		$.ajax {
			method: method,
			url: url,
			data: data,
			error: (output) ->
				item.show('fade')
			success: (output) ->
				item.remove()
				if list.children(".item:not([data-list-add])").length == 0
					list.children('[data-list-empty]').show('fade')
		}
					
$(document).on 'contentReady', () ->
	
	# we want javascript links to not scroll or reload when clicked
	$("a[href='']").attr 'href', 'javascript:void(0)'
	$("a[href='#']").attr 'href', 'javascript:void(0)'
	
	# hide some stuff by default
	$('.alert:empty').hide()
	$('.notice:empty').hide()
	$('[data-hide]').hide()
	
	# these elements are like links; click and go somewhere!
	$('[data-href]').when 'click.href', (event) ->
		if $(@).closest('[data-href-stop]').length > 0
			return
		if event.which == 1
			window.location = $(@).data 'href'
		
	# these elements are resized so the smallest side is as
	# long as the value specified
	$('[data-square]').when 'load.square', ->
		resizeImage $(@), $(@).data('square')
		
	# links which should remove a resource via ajax
	$("a[data-ajax-call='delete']").when 'click.ajax', (event) ->
		if event.which == 1
			event.stopPropagation()
			deleteClicked $(@), event
	
		
# make sure we trigger the event 'contentReady'
# whenever new content is ready (either the first DOM
# or new content via Ajax)
#
# Note:
# Since contentReady can be called several times, any
# handlers to other events that are bound during contentReady
# will thus be bound several times. For this reason .when()
# should be used instead of .on(), along with a scoped event,
# which will ensure that the handler is only called once when
# the event is triggered.
#
$ ->
	$(document).trigger 'contentReady'
	
$(document).on 'ajaxComplete', (event) ->
	$(document).trigger 'contentReady'