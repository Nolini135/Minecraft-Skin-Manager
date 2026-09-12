extends ColorRect

var desktop_scene = load("uid://8gd2yjyi8a5y")

func _ready() -> void:
	get_tree().call_deferred("change_scene_to_packed", desktop_scene)
