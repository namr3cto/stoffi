

# Creates a synchronizable object.
# 
# This is called when an object is created and we want to
# show it in real time for any user supposed to see it.
#
# @param object_type
#   The type of the object.
#
# @param object_params
#   The parameters of the object, encoded in JSON.
#
@createObject = (object_type, object_params) ->
	if embedded?
		try
			window.external.CreateObject object_type, object_params
		catch err
	else
		switch object_type
			when 'device'        then createDevice   object_params
			when 'playlist'      then createPlaylist object_params
			when 'listen'        then createListen   object_params
			when 'link'          then createink      object_params
	
# Updates a synchronizable object.
# 
# This is called when an object is changed and we want to
# modify it in real time for any user seeing it.
#
# @param object_type
#   The type of the object.
#
# @param object_id
#   The ID of the object.
#
# @param updated_params
#   The parameters that were changed, encoded in JSON.
#
@updateObject = (object_type, object_id, updated_params) ->
	if embedded?
		try
			window.external.UpdateObject object_type, object_id, update_params
		catch err
	else
		# general updates
		update object_type, object_id, JSON.parse(updated_params)
		
		# type-specific updates
		switch object_type
			when 'device'        then updateDevice   object_id, updated_params
			when 'configuration' then updateConfig   object_id, updated_params
			when 'playlist'      then updatePlaylist object_id, updated_params
			when 'listen'        then updateListen   object_id, updated_params
			when 'link'          then updateLink     object_id, updated_params
	
# Deletes a synchronizable object.
# 
# This is called when an object is deleted and we want to
# removed it in real time for any user seeing it.
#
# @param object_type
#   The type of the object.
#
# @param object_id
#   The ID of the object.#
#
@deleteObject = (object_type, object_id) ->
	if embedded?
		try
			window.external.DeleteObject object_type, object_id
		catch err
	else
		switch object_type
			when 'device'        then deleteDevice   object_id
			when 'playlist'      then deletePlaylist object_id
			when 'link'          then deleteLink     object_id

# Executes a command.
# 
# Sends the execution of a command.
#
# @param command
#   The command name.
#
# @param object_type
#   The type of the object.
#
# @param params
#   (Optional) Additional parameters of the command.
#
@execute = (command, object_type, params) ->
	if embedded?
		try
			window.external.Execute command, object_type, params
		catch err
	else
		switch object_type
			when 'device'        then executeDevice   command, params
			when 'playlist'      then executePlaylist command, params
			

#
# Update all fields of a resource.
#
# @param type
#   The type of the resource.
#
# @param id
#   The id of the resource.
#
# @param params
#   The parameters to update.
#
update = (type, id, params) ->
	items = $(getResource(type,id))
	
	# create a list of fields
	fields = []
	for field in items.find('[data-field]')
		resource = $(field).closest('[data-resource-id][data-resource-type]')
		if resource.data('resource-id') == id and resource.data('resource-type') == type
			fields.push field
	
	# update all fields
	for k,v of params
		for field in $(fields).filter("[data-field='#{k}']")
			
			# different actions depending on tag type
			switch ($(field).prop('tagName'))
				when 'INPUT' then $(field).val(v)
				when 'IMG' then $(field).attr('src', v)
				else $(field).html(v)