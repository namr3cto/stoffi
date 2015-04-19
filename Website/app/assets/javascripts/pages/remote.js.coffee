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

$(document).on 'contentReady', ->
	$('.volume.slider').when 'changed', ->
		volumeChanged()
		
	$('.remote .shuffle').when 'click', ->
		shuffleClicked()
		
	$('.remote .repeat').when 'click', ->
		repeatClicked()
		
	$('.remote .play-pause').when 'click', ->
		playPauseClicked()