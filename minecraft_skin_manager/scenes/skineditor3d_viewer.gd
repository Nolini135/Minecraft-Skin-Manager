extends SubViewportContainer
class_name SkinEditorViewer

@export var editor: TextureEditor


@export var skin_viewer_3d: Node3D
@export var camera_container: Node3D
@export var skin_wide: SkinEditorModel
@export var skin_slim: SkinEditorModel

var mouse_hover: bool = false
 

func _on_mouse_entered() -> void:
	mouse_hover = true

func _on_mouse_exited() -> void:
	mouse_hover = false

func apply_skin_to_model(root: Node3D, texture: Texture2D):
	for child in root.get_children():
		if child is MeshInstance3D:
			var mat = child.get_active_material(0).duplicate()
			mat.albedo_texture = texture
			child.set_surface_override_material(0, mat)
		elif child.get_child_count() > 0:
			apply_skin_to_model(child, texture)
