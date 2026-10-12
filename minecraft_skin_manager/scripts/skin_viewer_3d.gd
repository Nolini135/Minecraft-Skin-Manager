extends Node3D

@export var wide_editor: SkinEditorModel
@export var slim_editor: SkinEditorModel

@export_category("parts buttons references")
@export var head_button: TextureButton
@export var body_button: TextureButton
@export var arm_left_button: TextureButton
@export var arm_right_button: TextureButton
@export var leg_left_button: TextureButton
@export var leg_right_button: TextureButton

var current_editor: SkinEditorModel

# Part -> { "button": TextureButton, "size": Vector2i }
# "size" = taille d'une icône dans l'atlas : à gauche l'icône activée, à droite la désactivée.
var _part_buttons: Dictionary = {}


func _ready() -> void:
	assert(wide_editor != null and slim_editor != null, "wide_editor et slim_editor doivent être assignés")

	_part_buttons = {
		SkinEditorModel.Part.HEAD: {"button": head_button, "size": Vector2i(10, 11)},
		SkinEditorModel.Part.BODY: {"button": body_button, "size": Vector2i(10, 13)},
		SkinEditorModel.Part.RIGHT_ARM: {"button": arm_right_button, "size": Vector2i(4, 13)},
		SkinEditorModel.Part.LEFT_ARM: {"button": arm_left_button, "size": Vector2i(4, 13)},
		SkinEditorModel.Part.RIGHT_LEG: {"button": leg_right_button, "size": Vector2i(5, 13)},
		SkinEditorModel.Part.LEFT_LEG: {"button": leg_left_button, "size": Vector2i(5, 13)},
	}

	# Chaque bouton reçoit sa propre copie de la texture : modifier .region sur une
	# AtlasTexture partagée changerait l'icône des autres boutons.
	for part in _part_buttons:
		var button: TextureButton = _part_buttons[part]["button"]
		assert(button != null, "Un bouton de partie n'est pas assigné dans l'inspecteur")
		button.texture_normal = button.texture_normal.duplicate()

	current_editor = wide_editor
	slim_editor.disable()


######### Boutons des parties (signaux "pressed") #########

func _on_head_pressed() -> void:
	_toggle_part(SkinEditorModel.Part.HEAD)

func _on_body_pressed() -> void:
	_toggle_part(SkinEditorModel.Part.BODY)

func _on_arm_right_pressed() -> void:
	_toggle_part(SkinEditorModel.Part.RIGHT_ARM)

func _on_arm_left_pressed() -> void:
	_toggle_part(SkinEditorModel.Part.LEFT_ARM)

func _on_leg_right_pressed() -> void:
	_toggle_part(SkinEditorModel.Part.RIGHT_LEG)

func _on_leg_left_pressed() -> void:
	_toggle_part(SkinEditorModel.Part.LEFT_LEG)


######### Layers #########

func _on_layer_check_button_toggled(toggled_on: bool) -> void:
	for editor in [wide_editor, slim_editor]:
		editor.set_layer_enabled(toggled_on)


######### Choix du modèle #########

func _on_model_selector_item_selected(index: int) -> void:
	match index:
		0: # Wide
			current_editor = wide_editor
			wide_editor.enable()
			slim_editor.disable()
		1: # Slim
			current_editor = slim_editor
			wide_editor.disable()
			slim_editor.enable()


######### Interne #########

# Les deux modèles reçoivent toujours les mêmes changements, donc leur état reste synchronisé.
func _toggle_part(part: SkinEditorModel.Part) -> void:
	var enabled: bool = not current_editor.is_part_enabled(part)
	for editor in [wide_editor, slim_editor]:
		editor.set_part_enabled(part, enabled)
	_update_button(part, enabled)


func _update_button(part: SkinEditorModel.Part, enabled: bool) -> void:
	var info: Dictionary = _part_buttons[part]
	var size: Vector2i = info["size"]
	var x: int = 0 if enabled else size.x
	info["button"].texture_normal.region = Rect2(x, 0, size.x, size.y)
