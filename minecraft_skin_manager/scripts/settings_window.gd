extends Window
class_name SettingsWindow

@export var auto_save_spinbox: SpinBox
@export var theme_option: OptionButton
@export var bg_color_picker: ColorPicker
@export var bg_image_line_edit: LineEdit
@export var font_line_edit: LineEdit

func _on_close_requested() -> void:
	if visible:
		hide()
		save_changes()

func _is_about_to_popup() -> void:
	load_preferences()

func save_changes() -> void:
	SettingsManager.save_preferences()

func load_preferences() -> void:
	auto_save_spinbox.value = SettingsManager.get_saved_value("file", "auto_save_interval")
	
	for idx in range(theme_option.item_count):
		if theme_option.get_item_text(idx) == SettingsManager.get_saved_value("display", "theme", "dark"):
			theme_option.select(idx)
	
	bg_color_picker.color = Color.html(SettingsManager.get_saved_value("display", "background-color", "141414"))
	
	bg_image_line_edit.text = SettingsManager.get_saved_value("display", "background-image-path", "")
	
	font_line_edit.text = SettingsManager.get_saved_value("display", "font-path", "")


func _auto_save_changed(value: float):
	SettingsManager.auto_save_interval = value
	ImageSaver.reload_timer(value)

func _on_theme_selected(index: int) -> void:
	match index:
		0:
			ThemeManager.set_theme("dark")
			SettingsManager.theme = "dark"
		1:
			ThemeManager.set_theme("light")
			SettingsManager.theme = "light"

func _on_background_color_changed(color: Color) -> void:
	SettingsManager.bg_color = color.to_html()

func _on_bg_image_path_submitted(new_text: String) -> void:
	var formated_text: String = new_text.remove_chars('"')
	formated_text = formated_text.replace("\\", "/")
	
	if formated_text == "":
		SettingsManager.bg_image_path = ""
		return
	elif not FileAccess.file_exists(formated_text):
		printerr("file does not exists: %s" % formated_text)
		return
	
	var image = Image.load_from_file(formated_text)
	if image.get_width() > 0:
		EventBus.bg_image_changed.emit(image)
		
		SettingsManager.bg_image_path = formated_text
	else:
		printerr("cannot decode image file at %s" % formated_text)


func _on_font_path_submitted(new_text: String) -> void:
	var formated_text: String = new_text.remove_chars('"')
	formated_text = formated_text.replace("\\", "/")
	
	if formated_text == "":
		SettingsManager.font_path = ""
		return
	elif not FileAccess.file_exists(formated_text):
		printerr("file does not exists: %s" % formated_text)
		return
	
	SettingsManager.font_path = formated_text
