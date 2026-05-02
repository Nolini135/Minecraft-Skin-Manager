extends Node

var light_theme = preload("res://resources/themes/light_theme.tres")
var dark_theme = preload("res://resources/themes/dark_theme.tres")

@onready var bg_color = $"../BGColor"
@onready var menu_bar = $"../VBoxContainer/MenuBarContainer/MenuBar"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	apply_to_main()

func apply_to_main():
	var s = SettingsManager.settings
	if s == null:
		print("Settings not loaded yet")
		return
	
	match s.theme:
		"light":
			bg_color.color = Color(0.969, 0.969, 0.969, 1.0)
			menu_bar.theme = light_theme
		"dark":
			bg_color.color = Color(0.078, 0.078, 0.078, 1.0)
			menu_bar.theme = dark_theme
