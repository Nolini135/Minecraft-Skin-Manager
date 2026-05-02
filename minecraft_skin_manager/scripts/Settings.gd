extends Node

var settings: Settings

const SAVE_PATH = "user://settings.tres"


func _ready():
	load_settings()

	print("SettingsManager ready")
	load_settings()
	print("Settings loaded")


func load_settings():
	if FileAccess.file_exists(SAVE_PATH):
		settings = ResourceLoader.load(SAVE_PATH)
	else:
		settings = Settings.new()
		save_settings()

func save_settings():
	ResourceSaver.save(settings, SAVE_PATH)
