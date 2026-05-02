extends Window
class_name SettingsWindow

@onready var dark_theme = preload("res://resources/themes/dark_theme.tres")
@onready var light_theme = preload("res://resources/themes/light_theme.tres")

@export var ui_theme: OptionButton

@export var skin_folder_line_edit: LineEdit
@export var skin_folder_add_button: Button
@export var folder_array_element_container: Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var s = SettingsManager.settings
	
	if s.theme == "dark":
		$BG.theme = dark_theme
	elif s.theme == "light":
		$BG.theme = light_theme
	
	load_folder_array_elements()

	print("Preferences window ready")


func _on_visibility_changed() -> void:
	if visible:
		load_folder_array_elements()


	

func load_folder_array_elements():
	if SettingsManager.settings == null:
		print("Settings not loaded yet")
		return
	

func _on_theme_option_item_selected(index: int) -> void:
	var s = SettingsManager.settings
	
	match index:
		0:
			s.theme = "light"
		1:
			s.theme = "dark"
	SettingsManager.save_settings()


func _on_close_requested() -> void:
	if visible:
		hide()   


func _on_save_button_pressed() -> void:
	SettingsManager.save_settings()
