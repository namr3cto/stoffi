slideTimer = null
slideDuration = 1000
slideDelay = 10000
numSlides = 10
currentSlide = 1

stopSlideshow = ->
	if slideTimer != null
		clearTimeout slideTimer
	
@startSlideshow = (number) ->
	stopSlideshow()
	slideTimer = setTimeout "nextSlide()", slideDelay
	currentSlide = number
	
@nextSlide = ->
	jumpToSlide (currentSlide % numSlides)+1, false

@jumpToSlide = (number, interactive = true) ->
	#trackEvent('Slideshow', 'Jump to ' + slideNames[number-1]);
	stopSlideshow();
	
	fadeOutDuration = if interactive then 0 else slideDuration
	$("#slide#{currentSlide}").fadeOut fadeOutDuration, ->
		$("#slide#{number}").fadeIn slideDuration
		currentSlide = number
		startSlideshow number

jQuery ->
	$('[data-slide]').click ->
		jumpToSlide $(@).data 'slide'
	startSlideshow 1