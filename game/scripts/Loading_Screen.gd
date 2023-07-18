class_name LoadingScreen extends Control


signal any_key_pressed

@export_category("Signals")
@export var any_key_pressed_signal_name: String = "any_key_pressed"

var _tween: Tween

@onready var _hint_is_loading: RichTextLabel = $HintIsLoading
@onready var _hint_press_any_key: RichTextLabel = $HintPressAnyKey
@onready var _progress_bar: ProgressBar = $ProgressBar


func _input(event):
	if event is InputEventKey || event is InputEventMouseButton:
		if event.pressed:
			emit_signal(any_key_pressed_signal_name)


func set_progressbar_value(value: float):
	_progress_bar.value = value
	if value == 100.0:
		change_to_press_any_key_hint()


func change_to_press_any_key_hint():
	_tween = create_tween()
	_tween.tween_property(_hint_is_loading, "modulate", \
		Color(modulate, 0.0), 1.0)
	_tween = create_tween()
	_tween.tween_property(_hint_press_any_key, "modulate", \
		Color(modulate, 1.0), 1.0)


func reset_and_fade_in():
	set_process(true)
	show()
	_progress_bar.value = 0.0
	_tween = create_tween()
	_tween.tween_property(self, "modulate", Color(modulate, 1.0), 0.5)
	await _tween.finished


func fade_out():
	_tween = create_tween()
	_tween.tween_property(self, "modulate", Color(modulate, 0.0), 0.5)
	await _tween.finished
	hide()
	set_process(false)
