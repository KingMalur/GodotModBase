class_name SceneSwitcher extends Node


@export_category("Signals")
@export var any_key_pressed_signal_name: String = "any_key_pressed"

@export_category("Nodes")
@export_node_path("Node") var scenes_node: NodePath

@export_category("Values")
@export_dir var scene_folder: String = "scenes"
@export_range(10, 100) var resource_polling_time_max: int = 100 #msec

var _show_loading_screen: bool = false

var _scenes: Node

var _progress = []
var _is_scene_loaded: bool = false
var _loading_scene_path: String
var _current_scene: Node
var _scene_load_status = 0

# Threading

@onready var _loading_screen: LoadingScreen = $LoadingScreen as LoadingScreen


# Can't use _init() because the exported variables are not usable there..
func _ready():
	_setup_nodes()
	_connect_signals()


@warning_ignore("unused_parameter")
func _process(delta):
	if _is_scene_loaded:
		set_process(false)
		return
	
	_scene_load_status = ResourceLoader.load_threaded_get_status( \
		_loading_scene_path, _progress)
	_loading_screen.set_progressbar_value(_progress[0] * 100)
	if _scene_load_status != ResourceLoader.THREAD_LOAD_LOADED:
		return
	
	_is_scene_loaded = true
	if !_show_loading_screen:
		_on_any_key_pressed()


# Can only load "high-level" scenes as default, sub-folders only when supplied in scene_name
func load_scene_by_name(scene_name: String, show_loading_screen: bool = true):
	var scene_path = (%Globals as Globals).resource_prefix.path_join( \
		scene_folder.path_join(scene_name))
	load_scene_by_path(scene_path, show_loading_screen)


func load_scene_by_path(scene_path: String, show_loading_screen: bool = true):
	if _loading_scene_path != "":
		Logger.error("Already loading SCENE: %s. Can't load SCENE: %s" % \
			[_loading_scene_path, scene_path], self)
		return
	
	_show_loading_screen = show_loading_screen
	if _show_loading_screen:
		_loading_screen.reset_and_fade_in()
	else:
		_loading_screen.hide()
	
	ResourceLoader.load_threaded_request(scene_path)
	
	_loading_scene_path = scene_path
	_is_scene_loaded = false
	set_process(true)


func _on_any_key_pressed():
	if !_is_scene_loaded:
		return
	
	var resource = ResourceLoader.load_threaded_get(_loading_scene_path)
	var next_scene = resource.instantiate()
	_change_scene(next_scene)
	
	# Reset
	_is_scene_loaded = false
	_loading_scene_path = ""
	
	if _show_loading_screen:
		_loading_screen.fade_out()


func _connect_signals():
	_loading_screen.connect(any_key_pressed_signal_name, _on_any_key_pressed)


func _change_scene(next_scene: Object, old_scene: Object = _current_scene):
	if !next_scene:
		return
	
	_add_scene(next_scene)
	_current_scene = next_scene
	
	if !old_scene:
		return
	_remove_scene(old_scene.name)


func _add_scene(scene: Object):
	if !scene:
		return
	_scenes.call_deferred("add_child", scene)


func _remove_scene(scene_name: String):
	for child in _scenes.get_children():
		if child.name != scene_name:
			continue
		_scenes.call_deferred("remove_child", child)
		child.call_deferred("queue_free")
		break


func _setup_nodes():
	_scenes = get_node(scenes_node)
	if _scenes == null:
		Logger.error("NO NODE found at: %s" % scenes_node, self)
		return
