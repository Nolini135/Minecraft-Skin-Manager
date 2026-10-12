class_name BackgroundColorThemeUpdater extends ColorRect

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var color_hex = SettingsManager.save_file.get_value("display", "background-color", "141414")
	#var hex_string: String = "0x" + color_hex + "ff"  # ajoute l'alpha opaque
	#var hex_int: int = hex_string.hex_to_int()
	color = Color.html(color_hex)
