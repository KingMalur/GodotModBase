extends Node


signal settings_changed(type, value)

class SettingType:
	const LANGUAGE: PackedStringArray = ["language"]
	# Audio
	const MUSIC_ON: PackedStringArray = ["audio", "music_on"]
	const MUSIC_VOLUME: PackedStringArray = ["audio", "music_volume"]
	const SOUND_ON: PackedStringArray = ["audio", "sound_on"]
	const SOUND_VOLUME: PackedStringArray = ["audio", "sound_volume"]
	# Graphics
	const TEXTURE_QUALITY: PackedStringArray = ["graphics", "texture_quality"]
	const SHADOW_QUALITY: PackedStringArray = ["graphics", "shadow_quality"]
	const REFLECTION_QUALITY: PackedStringArray = ["graphics", "reflection_quality"]
	const ANTI_ALIASING: PackedStringArray = ["graphics", "anti_aliasing_on"]
	const V_SYNC: PackedStringArray = ["graphics", "v_sync_on"]
	const FPS_LIMIT: PackedStringArray = ["graphics", "fps_limit"]


var _settings = {}
var _settings_path = "user://data/settings.json"
var _default_settings = {
	"language": "en",
	"audio": {
		"music_on": true,
		"sound_on": true,
		"music_volume": 100.0,
		"sound_volume": 100.0,
	},
	"graphics": {
		"texture_quality": "normal",
		"shadow_quality": "normal",
		"reflection_quality": "normal",
		"anti_aliasing_on": true,
		"v_sync_on": true,
		"fps_limit": 60.0,
	},
}


func _init():
	self.name = "Settings"
	
	@warning_ignore("static_called_on_instance")
	var settings_file_exists: bool = Tools.file_exists(_settings_path)
	if !settings_file_exists:
		@warning_ignore("static_called_on_instance")
		Tools.create_file(_settings_path)
		_set_default_settings()
	
	_settings = Tools.get_data_from_JSON(_settings_path)


func set_value(key_path: PackedStringArray, value):
	if key_path.size() <= 0:
		return
	_set_value(_settings, key_path, value)
	emit_signal("settings_changed", key_path, value)
	Logger.info("%s changed to: %s" % [key_path, value], self)


func get_value(key_path: PackedStringArray):
	if key_path.size() <= 0:
		return null
	return _get_value(_settings, key_path)


func save():
	Tools.write_data_to_JSON(_settings_path, _settings)
	Logger.info("Saved!", self)


func _set_default_settings():
	Tools.write_data_to_JSON(_settings_path, _default_settings)


func _set_value(dictionary: Dictionary, key_path: PackedStringArray, value):
	var current = key_path[0]
	if dictionary.has(current):
		if typeof(dictionary[current]) == TYPE_DICTIONARY:
			key_path.remove_at(0)
			_set_value(dictionary[current], key_path, value)
			return
		else:
			dictionary[current] = value
			return


func _get_value(dictionary: Dictionary, key_path: PackedStringArray):
	var current = key_path[0]
	if dictionary.has(current):
		if typeof(dictionary[current]) == TYPE_DICTIONARY:
			key_path.remove_at(0)
			return _get_value(dictionary[current], key_path)
		else:
			return dictionary[current]
