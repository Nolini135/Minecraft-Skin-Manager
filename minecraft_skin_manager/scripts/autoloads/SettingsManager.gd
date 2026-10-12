extends Node

const SAVE_PATH = "user://preferences.cfg"

@onready var save_file := ConfigFile.new()

@export_group("file")
@export var auto_save_interval: float = 30.0 # seconds
@export_group("display")
@export var theme: String = "dark"
@export var bg_color: String = "141414"
@export var bg_image_path: String = ""
@export var font_path: String = ""

func _ready():
	load_settings.call_deferred()

func load_settings():
	if save_file.load(SAVE_PATH) == OK:
		print("Preferences file loaded")
	else:
		print("No preferences file, using defaults")

	# If the key does not exists (new verion, first opened),
	# We conserve the variable's default value
	auto_save_interval = save_file.get_value("file", "auto_save_interval", auto_save_interval)
	theme = save_file.get_value("display", "theme", theme)
	bg_color = save_file.get_value("display", "background-color", bg_color)
	bg_image_path = save_file.get_value("display", "background-image-path", bg_image_path)
	font_path = save_file.get_value("display", "font-path", font_path)

	# re-write the file : create it if it does not exists,
	# we add new keys to the existing file
	save_preferences()

	ThemeManager.apply_font(font_path)
	ThemeManager.set_theme(theme)

func save_preferences():
	save_file.set_value("file", "auto_save_interval", auto_save_interval)
	
	save_file.set_value("display", "theme", theme)
	
	save_file.set_value("display", "background-color", bg_color)
	save_file.set_value("display", "background-image-path", bg_image_path)
	save_file.set_value("display", "font-path", font_path)
	
	save_file.save(SAVE_PATH)
	print("Preferences file saved at %s" % SAVE_PATH)

func get_saved_value(section: String, key: String, default: Variant = null) -> Variant:
	return save_file.get_value(section, key, default)
