switchTab = (tabName) ->
	if $('.active[data-tab]').data('tab') == tabName
		return
	window.location.hash = tabName
	$('.active[data-content]').removeClass 'active'
	$("[data-content='#{tabName}']").addClass 'active'
	$('.active[data-tab]').removeClass 'active'
	$("[data-tab='#{tabName}']").addClass 'active'
	
currentTab = ->
	tab = window.location.hash.substring 1
	
	# HACK: when returned from omniauth we see this anchor
	tab = 'accounts' if tab == '_=_'
	
	if tab == '' or $("[data-tab='#{tab}']").length == 0
		tab = $('[data-tab]:first').data('tab')
	tab

jQuery ->
	$('[data-tab]').on 'click', (event) ->
		switchTab $(this).data('tab')
	switchTab currentTab()