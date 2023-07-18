extends Node


signal locale_changed(locale)

var _translations: Dictionary = {}


func add_translation(translation: Translation, overwrite: bool = false):
	# Not in dictionary -> add new translation
	if !_translations.has(translation.locale):
		_translations[translation.locale] = translation
		TranslationServer.add_translation(translation)
		Logger.info("NEW translation: %s." % translation.locale, self)
		return
	
	# Already in dictionary -> add messages to translation and replace in TranslationServer
	var current_translation = _translations[translation.locale]
	var merged_translation = _merge_translations(current_translation, translation, overwrite)
	if !merged_translation:
		Logger.error("Could NOT merge translations of locale %s!" % translation.locale, self)
		Logger.error("New translations NOT added to locale %s." % translation.locale, self)
		return
		
	_translations[translation.locale] = merged_translation
	TranslationServer.remove_translation(current_translation)
	TranslationServer.add_translation(merged_translation)
	Logger.info("MERGED translation: %s." % translation.locale, self)


func _merge_translations(old: Translation, new: Translation, overwrite: bool = false):
	var translation = Translation.new()
	translation.locale = old.locale
	
	for message in old.get_message_list():
		translation.add_message(message, old.get_message(message))
	
	var messages = translation.get_message_list()
	for message in new.get_message_list():
		if messages.has(message) && !overwrite:
			continue
		# add_message overwrites but for that to function you have
		# to keep the original translation object around 눈_눈
		translation.add_message(message, new.get_message(message))
	
	return translation


func clear():
	_translations.clear()
	TranslationServer.clear()


func get_loaded_locales():
	return TranslationServer.get_loaded_locales()


func get_locale_name(locale: String):
	return TranslationServer.get_locale_name(locale)


func remove_translation(translation: Translation):
	TranslationServer.remove_translation(translation)


func get_locale():
	return TranslationServer.get_locale()


func set_locale(locale: String):
	TranslationServer.set_locale(locale)
	locale_changed.emit(locale)


func translate(message: String):
	return TranslationServer.translate(message)
