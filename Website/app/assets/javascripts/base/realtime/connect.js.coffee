# A timer used for to attempt to reconnect the
# communication channel in case of failure.
reconnector = null

# A list of the channels to subscribe to
channels = []

# The ID of the user
userID = null

# The ID of the current device
deviceID = null

# The ID of the session.
#
# Used to make sure we don't echo stuff back to the origin.
sessionID = null

# The realtime communication connection
connection = null

# The version of the website: stable, beta or alpha
version = 'stable'

#
# Get the hostname of the realtime communication endpoint.
#
@getHostname = ->
	switch window.location.hostname
		when 'www.stoffiplayer.com', 'stoffiplayer.com'
			'ws.stoffiplayer.com'
		else window.location.hostname

#
# Get the port number of the realtime communication endpoint.
#
@getPort = ->
	return 8443 if window.location.protocol == 'https:'
	return 8080

#
# Sets the session ID in the embedding client.
# 
# This is called when the real time communication channel is established
# in order to inform the embedding client of the session ID so it can be
# sent along any requests to prevent echoes.
#
# @param sessionID
#   The ID of the communication session.
#
setSessionID = (sID) ->
	sessionID = sID
	try
		if embedded?
			window.external.SetSessionID sessionID
	catch err
		#console.log "could not tell embedder of session ID: #{err}"

#
# Attempts to reconnect the realtime communication.
#
reconnect = ->
	# embedded systems have their own reconnection logic
	return if embedded?

	try
		clearInterval(reconnector) if reconnector?
		reconnector = setInterval () ->
			$.ajax {
				type: 'GET',
				url: document.url,
				cache: false,
				success: (output) ->
					location.reload()
			}
		, 5000
	catch err
		#alert "error attempting to reconnect: #{err}"

#
# Connects the realtime communicationc channel.
# 
# Will attempt to connect the socket.io channel to the Node.js server handling
# realtime communication.
#
connect = ->
	if connection?
		connection.unbind 'connect'
		connection.unbind 'disconnect'

	connection = new Juggernaut({
		secure: window.location.protocol == 'https:', 
		host: getHostname(), port: getPort()})

	connection.on 'connect', () ->
		try
			setSessionID connection.sessionID
			clearInterval(reconnectInterval) if reconnector?
		catch err
			alert err

	connection.on 'disconnect', () ->
		try
			setSessionID ''
			reconnect()
		catch err
	
	$.ajaxSetup {
		beforeSend: (xhr) ->
			xhr.setRequestHeader 'X-Session-ID', connection.sessionID
			xhr.setRequestHeader 'X-CSRF-Token', $('meta[name="csrf-token"]').attr('content')
	}

	connection.meta = { version: version }
	connection.meta['user_id'] = userID if userID?	
	connection.meta['device_id'] = deviceID if deviceID?
	
	for channel in channels
		connection.subscribe channel, (data) ->
			try
				eval data
			catch err
		
	# TODO: why cannot embedded browser see the 'connect' event?
	setTimeout ->
		setSessionID connection.sessionID
	, 2000
		
#
# Initialize the realtime communication parameters.
#
# @param uID
#   The user id.
#
# @param dID
#   The device id.
#
# @param c
#   A list of the channels to subscribe to.
#
# @param v
#   The version of the website (stable, beta, alpha).
#
@initRealtime = (uID, dID, c, v) ->
	userID = uID
	deviceID = dID
	channels = c
	version = v
	
$ ->
	url = "#{window.location.protocol}//#{getHostname()}:#{getPort()}"
	window.WEB_SOCKET_SWF_LOCATION = "#{url}/socket.io/WebSocketMain.swf"
	$.getScript "#{url}/application.js", () ->
		connect()