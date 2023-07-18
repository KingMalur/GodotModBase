class_name Globals extends Node


@export_category("Debug")
@export var is_editor_build: bool = false

@export_category("Values")
@export var version_number: String = "0.0.1"

@export_category("Paths")
@export var resource_prefix: String = "res://"
@export var user_prefix: String = "user://"
@export var mod_suffix: String = "zip"
@export var data_folder: String = "data/"
@export var locale_folder: String = "data/locales/"
@export var saves_folder: String = "data/saves/"
@export var mod_folder: String = "data/mods/"
@export var user_mod_folder: String = "data/mods/"
@export var active_mods_file_name: String = "_active_mods.json"
@export var first_scene: String = "MainMenu.tscn"

var game_install_directory: String
var user_directory: String


# Can't use _init() because the exported variables are not usable there..
func _ready():
	Logger.info("BUILD TYPE: %s" % ("EDITOR" if is_editor_build else "RELEASE"), self)
	_setup_paths()


func _setup_paths():
	# Set install directory
	if is_editor_build:
		game_install_directory = ProjectSettings.globalize_path(resource_prefix)
	else:
		game_install_directory = OS.get_executable_path().get_base_dir()
		if OS.get_name() == "OSX": # OSX is a bit more nested
			game_install_directory = game_install_directory.get_base_dir().get_base_dir().get_base_dir()
	@warning_ignore("static_called_on_instance")
	game_install_directory = Tools.add_slash(game_install_directory)
	
	# Set working directory
	user_directory = ProjectSettings.globalize_path(user_prefix)
	@warning_ignore("static_called_on_instance")
	Tools.add_slash(user_directory)
	@warning_ignore("static_called_on_instance")
	Tools.create_dir(user_directory)
	
	# Set paths in install directory
	@warning_ignore("static_called_on_instance")
	data_folder = Tools.add_slash(game_install_directory + data_folder)
	@warning_ignore("static_called_on_instance")
	locale_folder = Tools.add_slash(game_install_directory + locale_folder)
	@warning_ignore("static_called_on_instance")
	mod_folder = Tools.add_slash(game_install_directory + mod_folder)
	
	# Set paths in working directory
	@warning_ignore("static_called_on_instance")
	user_mod_folder = Tools.add_slash(user_directory + user_mod_folder)
	@warning_ignore("static_called_on_instance")
	Tools.create_dir(user_mod_folder)
	@warning_ignore("static_called_on_instance")
	saves_folder = Tools.add_slash(user_directory + saves_folder)
	@warning_ignore("static_called_on_instance")
	Tools.create_dir(saves_folder)
