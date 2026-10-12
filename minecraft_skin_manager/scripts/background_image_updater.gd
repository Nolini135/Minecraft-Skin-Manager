class_name BackgroundImageTexture extends TextureRect

func _ready() -> void:
	var image_path: String = SettingsManager.save_file.get_value(
		"display",
		"background-image-path",
		""
		)
	
	if image_path == "":
		return
	
	var image = Image.load_from_file(image_path)
	if image:
		_change_image(image)
	
	EventBus.bg_image_changed.connect(_change_image)

func _change_image(image: Image):
	if image:
		var new_texture := ImageTexture.new()
		texture = new_texture.create_from_image(image)
		print("background image loaded")
	else:
		push_warning("cannot load background image")
