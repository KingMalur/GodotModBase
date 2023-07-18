# ModLoader based on https://gitlab.com/Delta-V-Modding/Mods/-/blob/main/game/ModLoader.gd

extends Node

# Config
#=======================================================================

const MODLOADER_VERSION = "0.0.1"
const MOD_LOG_PATH = "user://logs/"

var _mod_zip_files = {}
# Things to keep to ensure they don't get garbage collected
var _saved_objects = []


func _init():
	return


func _ready():
	return


func get_active_mods():
	return _mod_zip_files


func activate_mod(path_to_mod_file: String):
	# Check if mod exists
	var global_path_to_mod_file = ProjectSettings.globalize_path(path_to_mod_file)
	@warning_ignore("static_called_on_instance")
	var file_exists: bool = Tools.file_exists(global_path_to_mod_file)
	if !file_exists:
		Logger.error("MOD not found at: %s" % global_path_to_mod_file, self)
		return
	if !ProjectSettings.load_resource_pack(global_path_to_mod_file, true):
		Logger.error("Failed to load MOD: %s" % global_path_to_mod_file, self)
		return
	
	# Activate mod
	var gdunzip = load("res://addons/gdunzip/gdunzip.gd").new()
	gdunzip.load(global_path_to_mod_file)
	for mod_file_path in gdunzip.files:
		# If found file is a ModMain.gd -> activate
		var mod_file_name: String = mod_file_path.get_file().to_lower()
		if mod_file_name.begins_with("modmain") and mod_file_name.ends_with(".gd"):
			_load_mod_resource(mod_file_path)
		elif mod_file_name == "properties.json":
			_load_mod_properties(mod_file_path)
		else:
			continue


func install_script_extension(child_script_path: String):
	var child_script = ResourceLoader.load(child_script_path)
	
	# Force Godot to compile the script now.
	# We need to do this here to ensure that the inheritance chain is
	# properly set up and multiple mods can chain-extend the same
	# class multiple times.
	# This is also needed to make Godot instantiate the extended class
	# when creating singletons.
	# The actual instance is thrown away.
	child_script.new()
	
	var parent_script = child_script.get_base_script()
	var parent_script_path = parent_script.resource_path
	Logger.info("Installing script extension: %s <- %s." % \
		[parent_script_path, child_script_path], self)
	child_script.take_over_path(parent_script_path)


func add_translation_from_JSON(json_path: String, overwrite: bool = false):
	Tools.add_translation_from_JSON(json_path, overwrite)


func append_node_in_scene(modified_scene, node_name: String = "", \
	node_parent = null, instance_path: String = "", is_visible: bool = true):
	var new_node
	if instance_path != "":
		new_node = load(instance_path).instance()
	else:
		new_node = Node.new()
	if node_name != "":
		new_node.name = node_name
	if is_visible == false:
		new_node.visible = false
	if node_parent != null:
		var tmpNode = modified_scene.get_node(node_parent)
		tmpNode.add_child(new_node)
		new_node.set_owner(modified_scene)
	else:
		modified_scene.add_child(new_node)
		new_node.set_owner(modified_scene)


func save_scene(modified_scene, scene_path: String):
	# Create new packed scene
	var packed_scene = PackedScene.new()
	packed_scene.pack(modified_scene)
	# Override resource path in cache
	packed_scene.take_over_path(scene_path)
	# Save so it doesn't get garbage collected
	_saved_objects.append(packed_scene)


func _load_mod_resource(file_path: String):
	var global_mod_file_name = "res://" + file_path
	var packed_script = load(global_mod_file_name)
	var script_instance = packed_script.new(self)
	script_instance.name = file_path.get_base_dir()
	add_child(script_instance)
	Logger.info("Activated MOD: %s" % packed_script.resource_path, self)


func _load_mod_properties(file_path: String):
	var global_mod_file_name = "res://" + file_path
	var json_result = Tools.get_data_from_JSON(global_mod_file_name)
	if json_result != null:
		_mod_zip_files[json_result["id"]] = json_result
	else:
		Logger.error("Failed to load MOD PROPERTIES: %s" % global_mod_file_name, self)
