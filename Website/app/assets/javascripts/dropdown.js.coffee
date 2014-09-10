$ ->
	$(".dropdown-label").click (event) ->
		menu = $(@).parent().children '.dropdown-menu'
		if menu.is(':visible')
			menu.hide()
		else
			menu.show()
		event.stopPropagation()