shuffleClicked = ->
	btn = $('.remote .shuffle')
	state = btn.attr 'data-button-state'
	newState = if state == 'on' then 'off' else 'on'
	updateConfiguration -1, { shuffle: newState }

repeatClicked = ->
	btn = $('.remote .repeat')
	state = btn.attr 'data-button-state'
	newState = switch state
		when 'all' then 'one'
		when 'one' then 'off'
		when 'off' then 'all'
		else 'all'
	updateConfiguration -1, { repeat: newState }
	
playPauseClicked = ->
	executeRemote 'play-pause'
	
volumeChanged = ->
	slider = $('.remote .volume-slider')
	value = slider.data 'slider-value'
	updateConfiguration -1, { volume: value }
	
fixLineHeights = ->
	stretch = $('article.remote').css('position') == 'absolute'
		
	for e in ['button', 'current-song', 'volume']
		if stretch
			h = $("article.remote span.#{e}").height()
			$("article.remote span.#{e}").css 'line-height', "#{h}px"
		else
			$("article.remote span.#{e}").css 'line-height', "initial"
			
refreshDevice = (element) ->
	element = $(element)
	device = element.val()
	remote = element.closest '.remote'
	remote.attr 'data-remote-device', device
	
$ ->
	if $('#fullscreen_mode').length > 0 and navigator.userAgent.match(/(iPad|iPhone|Chrome)/i)
		$(document).on 'touchstart', (e) ->
			e.preventDefault()
		$(document).on 'touchmove', (e) ->
			e.preventDefault()

$(document).on 'contentReady', ->
	$('.volume.slider').when 'changed', ->
		volumeChanged()
		
	$('.remote .shuffle').when 'click', ->
		shuffleClicked()
		
	$('.remote .repeat').when 'click', ->
		repeatClicked()
		
	$('.remote .play-pause').when 'click', ->
		playPauseClicked()
		
	$('.remote #device').when 'change', ->
		refreshDevice $(@)
		
	$('.remote .back').when 'click', ->
		window.history.back()
		
	fixLineHeights()
	$(window).when 'resize', ->
		fixLineHeights()