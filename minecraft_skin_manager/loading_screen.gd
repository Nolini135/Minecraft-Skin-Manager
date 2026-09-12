extends ColorRect

var scene: PackedScene

func _ready() -> void:
	if OS.has_feature("linux"):
		await get_tree().create_timer(1.0).timeout
		
		var capture = get_viewport().get_texture().get_image()
		
		var image_path = OS.get_executable_path().get_base_dir() + "/test_affichage.png"
		capture.save_png(image_path)
		
		print("--- SCREENSHOT SAVED AT : ", image_path, " ---")
	
	if OS.has_feature("mobile"):
		scene = load("uid://c6t8hqesiovac")
	else:
		scene = load("uid://8gd2yjyi8a5y")
	
	await get_tree().create_timer(1).timeout
	
	get_tree().call_deferred("change_scene_to_packed", scene)
	
