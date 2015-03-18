followClicked = (element, event) ->
	url = element.closest('[data-resource-url]').data('resource-url')+'/follow.json'
	type = element.closest('[data-resource-type]').data('resource-type')
	id = element.closest('[data-resource-id]').data('resource-id')
	item = element.closest('.item')
	
	execute 'follow', type, id
	
	$.ajax {
		method: 'put',
		url: url,
		error: (output) ->
			execute 'unfollow', type, id
	}

unfollowClicked = (element, event) ->
	url = element.closest('[data-resource-url]').data('resource-url')+'.json'
	type = element.closest('[data-resource-type]').data('resource-type')
	id = element.closest('[data-resource-id]').data('resource-id')
	item = element.closest('.item')
	
	execute 'unfollow', type, id
	
	$.ajax {
		method: 'delete',
		url: url,
		error: (output) ->
			execute 'follow', type, id
	}
					
$(document).on 'contentReady', ->
	$("a[data-ajax-call='unfollow']").when 'click.followable', (event) ->
		if event.which == 1
			event.stopPropagation()
			unfollowClicked $(@), event
			
	$("a[data-ajax-call='follow']").when 'click.followable', (event) ->
		if event.which == 1
			event.stopPropagation()
			followClicked $(@), event