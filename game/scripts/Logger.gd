extends Node


@export_range (10, 100) var time_max: int = 100 # msec

var _is_debug_enabled = true

var _log_file_dir = "user://data/logs"
var _log_file_name = "session"
var _log_file_extension = "log"
var _log_file_path

var _startup_time

var _print_queue = []


func _init():
	for arg in OS.get_cmdline_args():
		if arg == "--debug" or arg == "-d":
			_is_debug_enabled = true


func _ready():
	# Setup session log
	@warning_ignore("static_called_on_instance")
	_startup_time = Tools.get_datetime_as_string()
	_log_file_path = _log_file_dir.path_join(_log_file_name + "_" + \
		_startup_time + "." + _log_file_extension)
	@warning_ignore("static_called_on_instance")
	Tools.create_file(_log_file_path)
	
	# Remove old session logs
	_remove_old_logs()
	
	if _is_debug_enabled:
		info("DEBUG ENABLED", self)
	
	set_process(false)


func _process(_delta):
	if _print_queue.size() <= 0:
		set_process(false)
	
	var t = Time.get_ticks_msec()
	while Time.get_ticks_msec() < t + time_max:
		if _print_queue.size() <= 0:
			break
		
		var message = _print_queue[0]
		_print_queue.remove_at(0)
		_print(message)


func debug(message: String, caller: Object):
	if _is_debug_enabled:
		_add_to_print_queue("DEBUG", message, caller)


func error(message: String, caller: Object):
	_add_to_print_queue("ERROR", message, caller)


func info(message: String, caller: Object):
	_add_to_print_queue("INFO", message, caller)


func _add_to_print_queue(type: String, message: String, caller: Object):
	set_process(true)
	@warning_ignore("static_called_on_instance")
	var date_time = Tools.get_datetime_as_string("-", " ", ":")
	
	var caller_name
	if caller != null:
		caller_name = caller.name
	else:
		caller_name = "NO_OBJECT"
	
	_print_queue.append("%s: %s - %s: %s" % \
		[date_time, type, caller_name, message])


func _print(message: String):
	_save_to_file(message)
	print(message)


func _save_to_file(message: String):
	@warning_ignore("static_called_on_instance")
	Tools.create_file(_log_file_path)
	# Append to log file
	var _log_file = FileAccess.open(_log_file_path, FileAccess.READ_WRITE)
	_log_file.seek_end()
	_log_file.store_string(message + "\n")
	_log_file = null


func _remove_old_logs():
	# Get all log files
	var log_files = Tools.get_files_in_path(_log_file_dir, _log_file_extension)
	
	# Delete all but the last 5 session logs
	if log_files.size() > 5:
		log_files.sort()
		log_files.reverse()
		for i in range(5, log_files.size()):
			@warning_ignore("static_called_on_instance")
			Tools.delete_file(log_files[i])
