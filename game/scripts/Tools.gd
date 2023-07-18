extends Node


static func get_datetime_as_string( \
	date_delimiter: String = "_", \
	time_delimiter: String = "_", \
	date_time_seperator: String = "-"):
	
	var date_time: Dictionary = Time.get_datetime_dict_from_system(false)
	
	var date_format = "%d" + date_delimiter + "%02d" + date_delimiter + "%02d"
	var time_format = "%02d" + time_delimiter + "%02d" + time_delimiter + "%02d"
	
	var formatted_date = date_format % [date_time["year"], date_time["month"], date_time["day"]]
	var formatted_time = time_format % [date_time["hour"], date_time["minute"], date_time["second"]]
	
	return formatted_date + date_time_seperator + formatted_time


static func add_slash(path: String):
	var new_path = path
	if !new_path.ends_with("/"):
		new_path += "/"
	return new_path


static func delete_file(file_path: String):
	var dir = DirAccess.open(file_path.get_base_dir())
	if !dir:
		return false
	
	return true if dir.remove(file_path) == OK else false


static func file_exists(file_path: String):
	return FileAccess.file_exists(file_path)


static func dir_exists(dir_path: String):
	return true if DirAccess.open(dir_path) else false


static func delete_files(file_paths: PackedStringArray):
	for file_path in file_paths:
		delete_file(file_path)


static func create_file(file_path: String):
	# Create directory
	create_dir(file_path.get_base_dir())
	
	# Create file
	if !FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.WRITE)
		# Just open & close is not enough to create a file, it needs some "data" in it..
		# even if it's an empty string <- that still works ¯\_ツ)_/¯
		file.store_string("")
		file = null


static func get_file_name(file_path: String, suffix: String):
	return file_path.get_file().trim_suffix(suffix)


static func create_dir(dir_path: String):
	var path = ProjectSettings.globalize_path(dir_path)
	
	var err = DirAccess.make_dir_recursive_absolute(path)
	if err != OK:
		Logger.error("Can't create directory: %s - with error: %s." % \
			[path, err], null)
		return


func save_screenshot( \
	file_path: String, view_port: Viewport, \
	width: int = 256, height: int = 144):
	
	var image = view_port.get_texture().get_data()
	image.flip_y()
	image.resize(width, height)
	image.save_png(file_path)


func get_texture_from_png(file_path: String):
	var image = get_image_from_png(file_path)
	if !image:
		return null
	
	return ImageTexture.create_from_image(image)


func get_image_from_png(file_path: String):
	var file = FileAccess.open(file_path, FileAccess.READ)
	if !file:
		Logger.error("Can't open file: %s - with error: %s." % \
			[file_path, FileAccess.get_open_error()], self)
		return null
	
	var bytes = file.get_buffer(file.get_length())
	file = null
	
	var image = Image.new()
	if image.load_png_from_buffer(bytes) != OK:
		Logger.error("Can't load texture from image: %s." % file_path, self)
		return null
	
	return image


func add_translation_from_JSON(json_path: String, overwrite: bool = false):
	var json_result = get_data_from_JSON(json_path)
	
	# Load locale
	var translation_object = Translation.new()
	translation_object.locale = json_result["locale"]
	# Load messages
	var messages = json_result["messages"]
	for message_key in messages.keys():
		translation_object.add_message(message_key, messages[message_key])
	
	# Install translation
	TranslationService.add_translation(translation_object, overwrite)


func get_data_from_JSON(json_path: String):
	# Does is exist?
	@warning_ignore("static_called_on_instance")
	var json_file_exists: bool = file_exists(json_path)
	if !json_file_exists:
		Logger.error("No .json file found at: %s." % json_path, self)
		return null
	# Can I open it?
	var json_file = FileAccess.open(json_path, FileAccess.READ)
	if !json_file:
		Logger.error("Error: %s - occured opening .json file at: %s." % \
			[FileAccess.get_open_error(), json_path], self)
		return null
	
	# Read JSON data
	var json_data = json_file.get_as_text()
	# Parse JSON data)
	var parsed_json_data = JSON.parse_string(json_data)
	if parsed_json_data == null:
		Logger.error("Error: %s - occured parsing .json file at: %s." % \
			[JSON.new().get_error_message(), json_path], self)
		return null
	
	json_file = null
	return parsed_json_data


func write_data_to_JSON(json_path: String, data: Dictionary):
	# Does is exist?
	@warning_ignore("static_called_on_instance")
	var json_file_exists: bool = file_exists(json_path)
	if !json_file_exists:
		@warning_ignore("static_called_on_instance")
		create_file(json_path)
	# Can I open it?
	var json_file = FileAccess.open(json_path, FileAccess.WRITE)
	if !json_file:
		Logger.error("Error: %s - occured opening .json file at: %s." % \
			[FileAccess.get_open_error(), json_path], self)
		return
	
	# Parse JSON data
	var json_data = JSON.stringify(data, "\t")
	
	# Store JSON data in file
	# Save and load data in a loop since sometimes a } gets added at the files end for some reason..
	# It's not in the jsonData string and validate_json does not have an error..
	json_file.store_string(json_data)
	json_file = null


func get_files_in_path(path: String, suffix: String = "") -> Array:
	path = ProjectSettings.globalize_path(path)
	var files = []
	
	# Check if folder is OK
	var dir = DirAccess.open(path)
	if !dir:
		# No folder
		Logger.error("Can't open folder: %s." % path, self)
		return files
	if dir.list_dir_begin() != OK:
		# No access
		Logger.error("Can't read folder: %s." % path, self)
		return files
	
	# Read files
	while true:
		var file_name = dir.get_next()
		if file_name == '':
			# Read the last file name in last iteration of loop -> no next file
			break
		if dir.current_is_dir():
			# Don't read directories, only read files
			continue
		if suffix != "":
			if file_name.get_extension() != suffix:
				continue
		var file_path = path.path_join(file_name)
		var globalfile_path = ProjectSettings.globalize_path(file_path)
		files.push_back(globalfile_path)
	dir.list_dir_end()
	
	return files


	# Returns 1 if version1 is bigger and -1 if
	# version 2 is bigger and 0 if equal
func version_compare(version1: String, version2: String) -> int:
	# Split both versions by "."
	var arr1 = version1.split(".") as Array
	var arr2 = version2.split(".") as Array
	# Get length of both arrays
	var len1 = len(arr1)
	var len2 = len(arr2)
	
	# Convert to integer from string
	for i in range(0, len1):
		arr1[i] = int(arr1[i])
	for i in range(0, len2):
		arr2[i] = int(arr2[i])
	
	# Compare which list is bigger and filles
	# smaller list with zero (for unequal delimiters)
	if len1 > len2:
		for _i in range(len2, len1):
			arr2.append(0)
	elif len2 > len1:
		for _i in range(len1, len2):
			arr1.append(0)
	
	# Returns 1 if version1 is bigger and -1 if
	# version 2 is bigger and 0 if equal
	for i in range(len(arr1)):
		if arr1[i] > arr2[i]:
			return 1
		elif arr2[i] > arr1[i]:
			return -1
	
	return 0
