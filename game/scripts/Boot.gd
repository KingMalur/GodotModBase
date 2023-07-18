extends Node


@export_category("Node Setup")
@export var singleton_node_name: String
@export_node_path("Node") var objects_node: NodePath
@export_node_path("Node") var globals_node: NodePath
@export_node_path("Node") var scene_switcher_node: NodePath

@export_category("Values")
@export var show_loading_screen_on_first_load: bool = false

var _singleton_node: Node
var _singletons: Array
var _objects_node: Node

var _globals: Globals
var _scene_switcher: SceneSwitcher


# Can't use _init() because the exported variables are not usable there..
func _ready():
	# In a real production project this would need serious error handling!
	# Setup nodes
	_setup_nodes()
	# Add Translations from locales-folder
	_add_locales()
	# Load persistant game data
	_load_persistant_data()
	# Set game locale
	_set_game_locale()
	# Load main menu
	_load_first_scene()
	# Load required mods (e.g. expansions)
	_load_required_mods()
	# Load optional mods
	_load_optional_mods()
	# Reparent nodes
	_reparent_nodes()
	# Delete self
	queue_free()


func _setup_nodes():
	# Objects
	_objects_node = get_node(objects_node)
	if !_objects_node:
		Logger.error("Can't find OBJECTS node at: %s" % objects_node, self)
		return
	# Globals
	_globals = get_node(globals_node)
	if !_globals:
		Logger.error("Can't find GLOBALS node at: %s" % globals_node, self)
		return
	# SceneSwitcher
	_scene_switcher = get_node(scene_switcher_node)
	if !_scene_switcher:
		Logger.error("Can't find SCENE SWITCHER node at: %s" % scene_switcher_node, self)
		return
	# Singletons
	# Create the singleton node instead of accessing it directly to have a
	# node structure like the following in the end -> Easy hierachy
	# root
	# 	Objects
	# 	Autoload
	_singleton_node = Node.new()
	_singleton_node.name = singleton_node_name
	get_tree().root.call_deferred("add_child", _singleton_node)
	_singleton_node.call_deferred("set_owner", get_tree().root)
	# Get all autoloaded Singletons to later add them as _singleton_node children
	var children = get_tree().root.get_children()
	for i in range(0, children.size()):
		if children[i].name != _objects_node.name:
			_singletons.append(children[i])


func _add_locales():
	var locale_files = Tools.get_files_in_path(_globals.locale_folder, "json")
	if locale_files.size() > 0:
		for locale_file in locale_files:
			Tools.add_translation_from_JSON(locale_file)


func _load_persistant_data():
	var data_files = Tools.get_files_in_path(_globals.data_folder, "json")
	if data_files.size() > 0:
		for data_file in data_files:
			# Load data from data_file
			Logger.info("Loading file: %s" % data_file, self)


func _load_required_mods():
	Logger.info("Looking for mods in %s" % _globals.mod_folder, self)
	_load_mods_from_json(_globals.mod_folder + \
		_globals.active_mods_file_name)


func _load_optional_mods():
	Logger.info("Looking for mods in %s" % _globals.user_mod_folder, self)
	_load_mods_from_json(_globals.user_mod_folder + \
		_globals.active_mods_file_name)


func _load_mods_from_json(mod_path: String):
	# Read all active mods
	var active_mods = Tools.get_data_from_JSON(mod_path) as Array
	if active_mods.size() <= 0:
		return
	
	# Get properties of active mods from file system
	var active_mods_properties = _get_mod_properties(active_mods, \
		mod_path.get_base_dir())
	if active_mods_properties.size() <= 0:
		for active_mod in active_mods:
			Logger.error("MOD NOT found: %s" % active_mod, self)
		return
	
	# Deactivate mods that aren't compatible based on min_ & max_game_version
	for active_mod_property in active_mods_properties:
		var mod_properties = active_mods_properties[active_mod_property]
		
		var version_smaller = Tools.version_compare(_globals.version_number, \
			mod_properties["min_game_version"])
		var version_greater = Tools.version_compare(_globals.version_number, \
			mod_properties["max_game_version"])
		
		if version_smaller < 0:
			active_mods_properties.erase(active_mod_property)
			Logger.error("VERSION CONFLICT (req.: %s != cur: %s) of MOD: %s" % \
				[mod_properties["min_game_version"], _globals.version_number, \
				mod_properties["id"]], self)
		elif version_greater > 0:
			active_mods_properties.erase(active_mod_property)
			Logger.error("VERSION CONFLICT (req.: %s != cur: %s) of MOD: %s" % \
				[mod_properties["max_game_version"], _globals.version_number, \
				mod_properties["id"]], self)
	
	# Check activated mods against mod files
	for active_mod in active_mods:
		if !active_mods_properties.has(active_mod):
			Logger.error("MOD NOT found: %s" % active_mod, self)
			continue
		
		var mod_properties = active_mods_properties[active_mod]
		Logger.info("MOD found: %s" % active_mod, self)
		ModLoader.call_deferred("activate_mod", mod_properties["file_path"])


func _set_game_locale():
	var locale = Settings.get_value(Settings.SettingType.LANGUAGE)
	if !TranslationService.get_loaded_locales().has(locale):
		locale = "en" # Fallback to english
	
	TranslationService.set_locale(locale)


func _load_first_scene():
	_scene_switcher.load_scene_by_name(_globals.first_scene, \
			show_loading_screen_on_first_load)


func _reparent_nodes():
	# Reparent children
	for i in range(0, get_child_count()):
		_reparent_single_node(get_child(i), _objects_node)
	# Reparent autoloaded singletons
	for i in range(0, _singletons.size()):
		_reparent_single_node(_singletons[i], _singleton_node)


func _reparent_single_node(to_reparent, new_parent):
	# Remove child of old parent
	to_reparent.get_parent().call_deferred("remove_child", to_reparent)
	# Then add child to new parent
	new_parent.call_deferred("add_child", to_reparent)
	# At last tell child about its new parent
	to_reparent.call_deferred("set_owner", new_parent)


func _get_mod_properties(active_mods: Array, mod_folder_path: String):
	var active_mod_dictionary = {}
	
	# Get mod files present in mod folder
	var mod_paths_on_file_system = Tools.get_files_in_path(mod_folder_path, "zip")
	if mod_paths_on_file_system.size() <= 0:
		return active_mod_dictionary
	
	# Match mod files against active_mods
	var found_mods_paths_on_file_system: Array = Array()
	for mod_id in active_mods:
		for mod_path in mod_paths_on_file_system:
			if mod_id == mod_path.get_file().get_basename():
				found_mods_paths_on_file_system.append(mod_path)
				break
	if found_mods_paths_on_file_system.size() <= 0:
		return active_mod_dictionary
	
	# Read mod files of active mods found
	var _mod_zip_files = []
	for mod_path in found_mods_paths_on_file_system:
		var global_mod_path = ProjectSettings.globalize_path(mod_path)
		if ProjectSettings.load_resource_pack(global_mod_path, true):
			_mod_zip_files.append(mod_path)
			continue
		Logger.error("MOD failed to load: %s" % mod_path.get_file(), self)
	
	# Read all found Properties.json and add them to the dictionary
	for mod_path in _mod_zip_files:
		var gdunzip = load("res://addons/gdunzip/gdunzip.gd").new()
		gdunzip.load(mod_path)
		for mod_file_path in gdunzip.files:
			var mod_file_name = mod_file_path.get_file().to_lower()
			if mod_file_name != "properties.json":
				continue
			
			var global_mod_path = _globals.resource_prefix + mod_file_path
			var json_result = Tools.get_data_from_JSON(global_mod_path)
			if json_result == null:
				continue
			
			var data = {}
			data["id"] = json_result["id"]
			data["mod_version"] = json_result["mod_version"]
			data["min_game_version"] = json_result["min_game_version"]
			data["max_game_version"] = json_result["max_game_version"]
			if data["max_game_version"] == "":
				data["max_game_version"] = _globals.version_number
			data["file_path"] = mod_path
			active_mod_dictionary[json_result["id"]] = data
	_mod_zip_files = null
	
	return active_mod_dictionary
