extends Node

const AUTO_SAVE_PATH = "user://auto_save/"
const AUTO_SAVE_FILE_NAME = "auto_saved_skin.png"

var auto_save_timer := Timer.new()
var editor: TextureEditor

func _ready() -> void:
	auto_save_timer.one_shot = false
	auto_save_timer.wait_time = 30.0
	add_child(auto_save_timer)
	
	auto_save_timer.timeout.connect(_on_timer_timeout)
	
	auto_save_timer.start()

func reload_timer(value: float):
	auto_save_timer.stop()
	if value >= 1.0:
		auto_save_timer.wait_time = value
		auto_save_timer.start()

func _on_timer_timeout():
	DirAccess.make_dir_recursive_absolute(AUTO_SAVE_PATH)
	
	save_image_texture(editor.texture, AUTO_SAVE_PATH + AUTO_SAVE_FILE_NAME)

func save_image_texture(texture: ImageTexture, path: String):
	var img := texture.get_image()  # ton image de skin
	var err := img.save_png(path)
	
	if not err == OK:
		print("Save error :", err)
	else:
		print("save completed : %s" % path)

func load_auto_saved_texture():
	var image = Image.load_from_file(AUTO_SAVE_PATH + AUTO_SAVE_FILE_NAME)
	
	if !image:
		image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
		image.fill(Color(1.0, 1.0, 1.0, 1.0))
	
	return image
