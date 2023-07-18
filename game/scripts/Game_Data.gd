extends Node


var _globals: Globals
var _game_data = {}
var _default_game_data = {
	"player_name": "John Doe",
	"player_position": {
		"x": 0,
		"y": 0,
		"z": 0,
	},
}

var _game_data_file_name: String
var _game_data_file_extension = ".json"
var _game_data_file_path: String


func _ready():
	_globals = get_tree().root.find_child("Globals", true, false)
	_game_data = _default_game_data


func get_game_data_dir():
	return _globals.saves_folder


func get_game_data():
	return _game_data


func create_new_game_data():
	_game_data = _default_game_data
	_save_game_data()


func save_game_data():
	_save_game_data()


func load_game_data(game_data_path: String):
	_game_data = _load_game_data(game_data_path)


func _save_game_data(data: Dictionary = _game_data):
	# Build paths
	@warning_ignore("static_called_on_instance")
	_game_data_file_name = Tools.get_datetime_as_string("", "_", "") + "_" + \
		_globals.version_number + _game_data_file_extension
	_game_data_file_path = _globals.saves_folder.path_join(_game_data_file_name)
	var previewImagePath = _game_data_file_path.get_basename() + ".png"
	@warning_ignore("static_called_on_instance")
	Tools.create_dir(_globals.saves_folder)
	# Save screenshot for GameData
	Tools.save_screenshot(previewImagePath, get_viewport())
	# Save GameData to file
	Tools.write_data_to_JSON(_game_data_file_path, data)
	Logger.info("GameData saved!", self)


func _load_game_data(game_data_path: String):
	var data = Tools.get_data_from_JSON(game_data_path)
	return data
