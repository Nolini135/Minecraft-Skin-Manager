extends Panel

const HOVER_COLOR := Color(1.0, 1.0, 1.0, 1.0)
const IDLE_COLOR := Color(0.735, 0.735, 0.735, 1.0)

@export var wide_editor: SkinEditorModel
@export var slim_editor: SkinEditorModel

@export_category("parts buttons references")
@export var head_button: TextureButton
@export var body_button: TextureButton
@export var arm_left_button: TextureButton
@export var arm_right_button: TextureButton
@export var leg_left_button: TextureButton
@export var leg_right_button: TextureButton

@export var head_layer_button: TextureButton
@export var body_layer_button: TextureButton
@export var arm_left_layer_button: TextureButton
@export var arm_right_layer_button: TextureButton
@export var leg_left_layer_button: TextureButton
@export var leg_right_layer_button: TextureButton

var current_editor: SkinEditorModel

var body_enabled: bool = true
var arm_right_enabled: bool = true
var arm_left_enabled: bool = true
var leg_right_enabled: bool = true
var leg_left_enabled: bool = true
var head_enabled: bool = true

var layer_buttons: Dictionary = {}
var layers_enabled: Dictionary = {}

func _ready() -> void:
	current_editor = wide_editor
	slim_editor.disable()
	
	layer_buttons = {
		SkinEditorModel.Part.HEAD: head_layer_button,
		SkinEditorModel.Part.BODY: body_layer_button,
		SkinEditorModel.Part.LEFT_ARM: arm_left_layer_button,
		SkinEditorModel.Part.RIGHT_ARM: arm_right_layer_button,
		SkinEditorModel.Part.LEFT_LEG: leg_left_layer_button,
		SkinEditorModel.Part.RIGHT_LEG: leg_right_layer_button,
	}
	
	for part in layer_buttons:
		var button: TextureButton = layer_buttons[part]
		layers_enabled[part] = true
		button.pressed.connect(_on_layer_part_pressed.bind(part))
		button.mouse_entered.connect(_on_layer_part_hover.bind(button, true))
		button.mouse_exited.connect(_on_layer_part_hover.bind(button, false))

## Body Button

func _on_body_mouse_entered() -> void:
	body_button.self_modulate = Color(1.0, 1.0, 1.0, 1.0)

func _on_body_mouse_exited() -> void:
	body_button.self_modulate = Color(0.735, 0.735, 0.735, 1.0)

func _on_body_pressed() -> void:
	if body_enabled:
		wide_editor.set_part_enabled(SkinEditorModel.Part.BODY, false)
		slim_editor.set_part_enabled(SkinEditorModel.Part.BODY, false)
		
		body_button.texture_normal.region = Rect2(10, 0, 10, 13)
	else:
		wide_editor.set_part_enabled(SkinEditorModel.Part.BODY, true)
		slim_editor.set_part_enabled(SkinEditorModel.Part.BODY, true)
		
		body_button.texture_normal.region = Rect2(0, 0, 10, 13)
	body_enabled = not body_enabled


## Right Arm Button 

func _on_arm_right_mouse_entered() -> void:
	arm_right_button.self_modulate = Color(1.0, 1.0, 1.0, 1.0)

func _on_arm_right_mouse_exited() -> void:
	arm_right_button.self_modulate = Color(0.735, 0.735, 0.735, 1.0)

func _on_arm_right_pressed() -> void:
	if arm_right_enabled:
		wide_editor.set_part_enabled(SkinEditorModel.Part.RIGHT_ARM, false)
		slim_editor.set_part_enabled(SkinEditorModel.Part.RIGHT_ARM, false)
		
		arm_right_button.texture_normal.region = Rect2(4, 0, 4, 13)
	else:
		wide_editor.set_part_enabled(SkinEditorModel.Part.RIGHT_ARM, true)
		slim_editor.set_part_enabled(SkinEditorModel.Part.RIGHT_ARM, true)
		
		arm_right_button.texture_normal.region = Rect2(0, 0, 4, 13)
	arm_right_enabled = not arm_right_enabled

## Left Arm Button

func _on_arm_left_mouse_entered() -> void:
	arm_left_button.self_modulate = Color(1.0, 1.0, 1.0, 1.0)

func _on_arm_left_mouse_exited() -> void:
	arm_left_button.self_modulate = Color(0.735, 0.735, 0.735, 1.0)

func _on_arm_left_pressed() -> void:
	if arm_left_enabled:
		wide_editor.set_part_enabled(SkinEditorModel.Part.LEFT_ARM, false)
		slim_editor.set_part_enabled(SkinEditorModel.Part.LEFT_ARM, false)
		
		arm_left_button.texture_normal.region = Rect2(4, 0, 4, 13)
	else:
		wide_editor.set_part_enabled(SkinEditorModel.Part.LEFT_ARM, true)
		slim_editor.set_part_enabled(SkinEditorModel.Part.LEFT_ARM, true)
		
		arm_left_button.texture_normal.region = Rect2(0, 0, 4, 13)
	arm_left_enabled = not arm_left_enabled

## Right Leg Button

func _on_leg_right_mouse_entered() -> void:
	leg_right_button.self_modulate = Color(1.0, 1.0, 1.0, 1.0)

func _on_leg_right_mouse_exited() -> void:
	leg_right_button.self_modulate = Color(0.735, 0.735, 0.735, 1.0)

func _on_leg_right_pressed() -> void:
	if leg_right_enabled:
		wide_editor.set_part_enabled(SkinEditorModel.Part.RIGHT_LEG, false)
		slim_editor.set_part_enabled(SkinEditorModel.Part.RIGHT_LEG, false)
		
		leg_right_button.texture_normal.region = Rect2(5, 0, 5, 13)
	else:
		wide_editor.set_part_enabled(SkinEditorModel.Part.RIGHT_LEG, true)
		slim_editor.set_part_enabled(SkinEditorModel.Part.RIGHT_LEG, true)
		
		leg_right_button.texture_normal.region = Rect2(0, 0, 5, 13)
	leg_right_enabled = not leg_right_enabled

## Left Leg Button

func _on_leg_left_mouse_entered() -> void:
	leg_left_button.self_modulate = Color(1.0, 1.0, 1.0, 1.0)

func _on_leg_left_mouse_exited() -> void:
	leg_left_button.self_modulate = Color(0.735, 0.735, 0.735, 1.0)

func _on_leg_left_pressed() -> void:
	if leg_left_enabled:
		wide_editor.set_part_enabled(SkinEditorModel.Part.LEFT_LEG, false)
		slim_editor.set_part_enabled(SkinEditorModel.Part.LEFT_LEG, false)
		
		leg_left_button.texture_normal.region = Rect2(5, 0, 5, 13)
	else:
		wide_editor.set_part_enabled(SkinEditorModel.Part.LEFT_LEG, true)
		slim_editor.set_part_enabled(SkinEditorModel.Part.LEFT_LEG, true)
		
		leg_left_button.texture_normal.region = Rect2(0, 0, 5, 13)
	leg_left_enabled = not leg_left_enabled

## Head Button

func _on_head_mouse_entered() -> void:
	head_button.self_modulate = Color(1.0, 1.0, 1.0, 1.0)

func _on_head_mouse_exited() -> void:
	head_button.self_modulate = Color(0.733, 0.733, 0.733, 1.0)

func _on_head_pressed() -> void:
	if head_enabled:
		wide_editor.set_part_enabled(SkinEditorModel.Part.HEAD, false)
		slim_editor.set_part_enabled(SkinEditorModel.Part.HEAD, false)
		
		head_button.texture_normal.region = Rect2(10, 0, 10, 11)
	else:
		wide_editor.set_part_enabled(SkinEditorModel.Part.HEAD, true)
		slim_editor.set_part_enabled(SkinEditorModel.Part.HEAD, true)
		
		head_button.texture_normal.region = Rect2(0, 0, 10, 11)
	head_enabled = not head_enabled


## Layer Buttons

func _on_layer_part_hover(button: TextureButton, hovered: bool) -> void:
	button.self_modulate = HOVER_COLOR if hovered else IDLE_COLOR

func _on_layer_part_pressed(part: SkinEditorModel.Part) -> void:
	_set_layer_part_enabled(part, not layers_enabled[part])

func _set_layer_part_enabled(part: SkinEditorModel.Part, enabled: bool) -> void:
	layers_enabled[part] = enabled
	wide_editor.set_part_layer_enabled(part, enabled)
	slim_editor.set_part_layer_enabled(part, enabled)
	_update_button_region(layer_buttons[part], enabled)

# Même logique que tes boutons normaux : région à x=0 si activé,
# décalée d'une largeur si désactivé
func _update_button_region(button: TextureButton, enabled: bool) -> void:
	var region: Rect2 = button.texture_normal.region
	region.position.x = 0.0 if enabled else region.size.x
	button.texture_normal.region = region

## Bouton global (toggle de tous les layers d'un coup)

func _on_layer_check_button_toggled(toggled_on: bool) -> void:
	for part in layer_buttons:
		_set_layer_part_enabled(part, toggled_on)


func _on_model_selector_item_selected(index: int) -> void:
	match index:
		0: # Wide
			wide_editor.enable()
			slim_editor.disable()
			current_editor = wide_editor
		1: # Slim
			wide_editor.disable()
			slim_editor.enable()
			current_editor = slim_editor
