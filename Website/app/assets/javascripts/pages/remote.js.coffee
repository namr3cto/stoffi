shuffleClicked = ->
	btn = $('.remote .shuffle')
	c = getConfigID(btn)
	state = btn.attr 'data-button-state'
	newState = if state == 'on' then 'off' else 'on'
	updateConfiguration c, { shuffle: newState }
	sendUpdate c, { shuffle: newState }

repeatClicked = ->
	btn = $('.remote .repeat')
	c = getConfigID(btn)
	state = btn.attr 'data-button-state'
	newState = switch state
		when 'all' then 'one'
		when 'one' then 'off'
		when 'off' then 'all'
		else 'all'
	updateConfiguration c, { repeat: newState }
	sendUpdate c, { repeat: newState }
	
playPauseClicked = (config_id, device_id) ->
	executeRemote 'play-pause'
	isPlaying = $('.remote .play-pause').attr('data-button-state') == 'playing'
	cmd = isPlaying ? 'pause' : 'play'
	$.ajax {
		url: "/configurations/#{config_id}/#{cmd}.json",
		dataType: "json",
		type: "POST",
		data: { device_id: id }
	}
	
nextClicked = (config_id, device_id) ->
	$.ajax {
		url: "/configurations/#{config_id}/next.json",
		dataType: "json",
		type: "POST",
		data: { device_id: device_id }
	}
	
prevClicked = (config_id, device_id) ->
	$.ajax {
		url: "/configurations/#{config_id}/prev.json",
		dataType: "json",
		type: "POST",
		data: { device_id: device_id }
	}
	
volume_timer = {}
volumeChanged = ->
	slider = $('.remote .volume-slider')
	c = getConfigID(slider)
	value = slider.data 'slider-value'
	updateConfiguration c, { volume: value }
	
	if volume_timer[config_id]
		clearTimeout volume_timer[config_id]
		
	volume_timer[config_id] = setTimeout ->
		sendUpdate c, {"volume": value}
	, 500
	
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
	
	state = {}
	for x in ['now_playing', 'media_state', 'volume', 'shuffle', 'repeat']
		state[x] = $("device_#{device}_#{x}").val()
	updateConfiguration -1, state

#
# Sends an AJAX request updating a
# configuration's parameters.
#
# @param config_id
#   The ID of the config to manipulate.
#
# @param params
#   The parameters and their values.
#
sendUpdate = (config_id, params) ->
	$.ajax {
		url: "/configurations/#{config_id}.json",
		dataType: "json",
		data: {"configuration": params},
		type: 'PATCH'
	}
	
getDeviceID = (element) ->
	element.closest('[data-remote-device]').data 'remote-device'
	
getConfigID = (element) ->
	element.closest('[data-remote-configuration]').data 'remote-configuration'
	
$ ->
	if $('#fullscreen_mode').length > 0 and navigator.userAgent.match(/(iPad|iPhone|Chrome)/i)
		$(document).on 'touchstart', (e) ->
			e.preventDefault()
		$(document).on 'touchmove', (e) ->
			e.preventDefault()

$(document).on 'contentReady', ->
	$('.volume.slider').when 'changed', ->
		volumeChanged getConfigID($(@)), getDeviceID($(@))
		
	$('.remote .shuffle').when 'click', ->
		shuffleClicked getConfigID($(@)), getDeviceID($(@))
		
	$('.remote .repeat').when 'click', ->
		repeatClicked getConfigID($(@)), getDeviceID($(@))
		
	$('.remote .next').when 'click', ->
		nextClicked getConfigID($(@)), getDeviceID($(@))
		
	$('.remote .previous').when 'click', ->
		prevClicked getConfigID($(@)), getDeviceID($(@))
		
	$('.remote .play-pause').when 'click', ->
		playPauseClicked getConfigID($(@)), getDeviceID($(@))
		
	$('.remote #device').when 'change', ->
		refreshDevice $(@)
		
	$('.remote .back').when 'click', ->
		window.history.back()
		
	fixLineHeights()
	$(window).when 'resize', ->
		fixLineHeights()