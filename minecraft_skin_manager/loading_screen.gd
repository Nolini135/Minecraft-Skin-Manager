extends ColorRect

var scene: PackedScene

func _ready() -> void:
	if OS.has_feature("mobile"):
		scene = load("uid://c6t8hqesiovac")
	else:
		scene = load("uid://8gd2yjyi8a5y")
	
	await get_tree().create_timer(1)
	
	get_tree().call_deferred("change_scene_to_packed", scene)
	
