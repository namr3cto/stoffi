
initMap = (div) ->
	lng = div.data('map-longitude')
	lat = div.data('map-latitude')
	zoom = div.data('map-zoom') || 3
	type = div.data('map-type') || 'terrain'
	mark = div.data('map-marker')
	pos = new google.maps.LatLng(lat, lng)
	i = null
	
	map = new google.maps.Map div[0], {
		zoom: zoom,
		center: pos,
		mapTypeId: type
	}
	
	map.setTilt(45)# if div.data('tilt')
	
	infowindow = new google.maps.InfoWindow()
	
	marker = new google.maps.Marker {
		position: pos,
		map: map
	}
	
	google.maps.event.addListener marker, 'click', ((marker, i) ->
		() ->
			infowindow.setContent mark
			infowindow.open map, marker
	)(marker, i)

$ ->
	initMap $(map) for map in $('[data-map]')