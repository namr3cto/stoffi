play = ->
	btn = $('.remote .play-pause')
	icn = btn.find('i.fa')
	icn.removeClass 'fa-play'
	icn.addClass 'fa-pause'
	btn.attr 'data-button-state', 'playing'
	
pause = ->
	btn = $('.remote .play-pause')
	icn = btn.find('i.fa')
	icn.removeClass 'fa-pause'
	icn.addClass 'fa-play'
	btn.attr 'data-button-state', 'paused'
	
playPause = ->
	btn = $('.remote .play-pause')
	if btn.attr('data-button-state') == 'playing'
		pause()
	else
		play()

@updateConfiguration = (id, params) ->
	if 'shuffle' of params
		btn = $('.remote .shuffle')
		btn.attr 'data-button-state', params['shuffle']
		
	if 'repeat' of params
		btn = $('.remote .repeat')
		lbl = $('.remote .repeat-label')
		if params['repeat'] == 'one' then lbl.show() else lbl.hide()
		btn.attr 'data-button-state', params['repeat']
		
	if 'volume' of params
		slider = $('.remote .volume-slider')
		slider.value(params['volume'])
		
@executeRemote = (command, params) ->
	switch command
		when 'play' then play()
		when 'pause' then pause()
		when 'play-pause' then playPause()