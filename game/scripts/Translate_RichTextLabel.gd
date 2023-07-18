extends RichTextLabel


@export var locale_changed_signal_name: String = "locale_changed"

var message: String


func _ready():
	TranslationService.connect(locale_changed_signal_name, _on_locale_changed)
	message = text


func _exit_tree():
	TranslationService.disconnect(locale_changed_signal_name, _on_locale_changed)


func _on_locale_changed(_locale):
	text = TranslationService.translate(message)
