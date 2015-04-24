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
	stretch = $('article#remote').css('position') == 'absolute'
		
	for e in ['button', 'current-song', 'volume']
		if stretch
			h = $("article#remote span.#{e}").height()
			$("article#remote span.#{e}").css 'line-height', "#{h}px"
		else
			$("article#remote span.#{e}").css 'line-height', "initial"
	
	#$("article#remote span.button").fitText(1.5)
	#$("article#remote span.volume").fitText(2)
	#$("article#remote span.current-song").fitText(3)
	
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
		
	#fixLineHeights()
	$(window).when 'resize', ->
		if $('article#remote').css('position') == 'absolute'
			$('footer').hide()
		else if $('article#remote').length > 0
			$('footer').show()
		fixLineHeights()