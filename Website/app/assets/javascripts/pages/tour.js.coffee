currentSlide = 0
isChangingSlide = false
tourSlides = [
	'youtube', 'sources', 'playlists', 'interface',
	'shortcuts', 'bookmarks', 'jumplists', 'formats',
	'focus', 'settings', 'history', 'backup', 'quickedit',
	'equalizer', 'generator'
]

updateSlide = ->
	slide = tourSlides[currentSlide]
	img = "/assets/#{locale}/tour/#{slide}.png"
	title = trans[locale]['tour.'+slide+'.title']
	text1 = trans[locale]['tour.'+slide+'.text1']
	text2 = trans[locale]['tour.'+slide+'.text2']
	text = '<p>'+text1+'</p><p>'+text2+'</p>'
	
	s = 500
	$("#text").fadeOut s
	$("#title").fadeOut s
	$("#image-wrap").fadeOut s, ->
		$("#image").replaceWith "<img src='"+img+"', id='image'/>"
		$('#image').load ->
			h = $('#image').height()
			$('.handle').css('height', "#{h}px")
			$('.handle').css('line-height', "#{h}px")
		$("#title").html title
		$("#text").html text
		$("#image-wrap").fadeIn s
		$("#title").fadeIn s
		$("#text").fadeIn s

$(document).on 'contentReady', () ->
	preloadImages tourSlides.map((i) -> "/assets/#{locale}/tour/#{i}.png")
	updateSlide()
	$('#prevSlide').when 'click.tour.slide', ->
		return if isChangingSlide
		#trackEvent 'Tour', 'Prev at ' + tourSlides[currentSlide];
		currentSlide = (currentSlide - 1 + tourSlides.length) % tourSlides.length;
		updateSlide();
		
	$('#nextSlide').when 'click.tour.slide', ->
		return if isChangingSlide
		#trackEvent 'Tour', 'Next at ' + tourSlides[currentSlide];
		currentSlide = (currentSlide + 1) % tourSlides.length;
		updateSlide();