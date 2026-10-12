extends Node

signal theme_changed(theme_name: String)
signal update_background(type: String)

var themes := {
	"dark": preload("uid://v01qaqdby2uw"),
	"light": preload("uid://dw2p8xo81ir0l")
}

var current_theme_name: String = "dark"

@onready var bg_color = $"../BGColor"
@onready var menu_bar = $"../VBoxContainer/MenuBarContainer/MenuBar"

func set_theme(theme_name: String):
	if not themes.has(theme_name):
		push_warning("unknown theme: %s" % theme_name)
		return
	current_theme_name = theme_name
	get_tree().root.theme = themes[theme_name]
	print("applied theme: %s " % theme_name)
	theme_changed.emit(theme_name)
	update_background.emit(SettingsManager.get_saved_value("display", "background-type", "theme"))

func apply_font(path: String):
	if path == "" or not FileAccess.file_exists(path):
		return
	
	var font := FontFile.new()
	var err := font.load_dynamic_font(path)
	if err != OK:
		push_warning("Cannot load font at %s" % path)
		return
	
	set_custom_font(font)

func set_custom_font(font: FontFile):
	for theme_name in themes:
		themes[theme_name].set_default_font(font)
	get_tree().root.theme = themes[current_theme_name]

func reload_theme():
	set_theme(current_theme_name)
