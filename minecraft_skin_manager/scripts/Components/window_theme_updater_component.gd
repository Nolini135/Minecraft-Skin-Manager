class_name WindowThemeUpdater extends Node


func _ready() -> void:
	ThemeManager.theme_changed.connect(change_theme)

func change_theme(theme_name: String):
	var window = get_parent()
	
	if window is Window:
		window.theme = ThemeManager.themes[theme_name]
