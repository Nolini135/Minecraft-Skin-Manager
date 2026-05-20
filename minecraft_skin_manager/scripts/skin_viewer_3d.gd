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

var body_enabled: bool = true
var arm_right_enabled: bool = true
var arm_left_enabled: bool = true
var leg_right_enabled: bool = true
var leg_left_enabled: bool = true
var head_enabled: bool = true

func _ready() -> void:
	current_editor = wide_editor
	
	slim_editor.disable()

func _on_body_pressed() -> void:
	if body_enabled:
		wide_editor.disable_node(wide_editor.body)
		wide_editor.disable_node(wide_editor.body_layer)
		
		slim_editor.disable_node(slim_editor.body)
		slim_editor.disable_node(slim_editor.body_layer)
		
		body_button.texture_normal.region = Rect2(10, 0, 10, 13)
	else:
		if wide_editor.layer_enabled:
			wide_editor.enable_node(wide_editor.body_layer)
			
			slim_editor.enable_node(slim_editor.body_layer)
		wide_editor.enable_node(wide_editor.body)
		slim_editor.enable_node(slim_editor.body)
		
		body_button.texture_normal.region = Rect2(0, 0, 10, 13)
	body_enabled = not body_enabled

func _on_arm_right_pressed() -> void:
	if arm_right_enabled:
		wide_editor.disable_node(wide_editor.right_arm)
		wide_editor.disable_node(wide_editor.right_arm_layer)
		
		slim_editor.disable_node(slim_editor.right_arm)
		slim_editor.disable_node(slim_editor.right_arm_layer)
		
		arm_right_button.texture_normal.region = Rect2(4, 0, 4, 13)
	else:
		if wide_editor.layer_enabled:
			wide_editor.enable_node(wide_editor.right_arm_layer)
			slim_editor.enable_node(slim_editor.right_arm_layer)
		
		wide_editor.enable_node(wide_editor.right_arm)
		slim_editor.enable_node(slim_editor.right_arm)
		
		arm_right_button.texture_normal.region = Rect2(0, 0, 4, 13)
	arm_right_enabled = not arm_right_enabled

func _on_arm_left_pressed() -> void:
	if arm_left_enabled:
		wide_editor.disable_node(wide_editor.left_arm)
		wide_editor.disable_node(wide_editor.left_arm_layer)
		
		slim_editor.disable_node(slim_editor.left_arm)
		slim_editor.disable_node(slim_editor.left_arm_layer)
		
		arm_left_button.texture_normal.region = Rect2(4, 0, 4, 13)
	else:
		if wide_editor.layer_enabled:
			wide_editor.enable_node(wide_editor.left_arm_layer)
			slim_editor.enable_node(slim_editor.left_arm_layer)
		
		wide_editor.enable_node(wide_editor.left_arm)
		slim_editor.enable_node(slim_editor.left_arm)
		
		arm_left_button.texture_normal.region = Rect2(0, 0, 4, 13)
	arm_left_enabled = not arm_left_enabled

func _on_leg_right_pressed() -> void:
	if leg_right_enabled:
		wide_editor.disable_node(wide_editor.right_leg)
		wide_editor.disable_node(wide_editor.right_leg_layer)
		
		slim_editor.disable_node(slim_editor.right_leg)
		slim_editor.disable_node(slim_editor.right_leg_layer)
		
		leg_right_button.texture_normal.region = Rect2(5, 0, 5, 13)
	else:
		if wide_editor.layer_enabled:
			wide_editor.enable_node(wide_editor.right_leg_layer)
			slim_editor.enable_node(slim_editor.right_leg_layer)
		
		wide_editor.enable_node(wide_editor.right_leg)
		slim_editor.enable_node(slim_editor.right_leg)
		
		leg_right_button.texture_normal.region = Rect2(0, 0, 5, 13)
	leg_right_enabled = not leg_right_enabled

func _on_leg_left_pressed() -> void:
	if leg_left_enabled:
		wide_editor.disable_node(wide_editor.left_leg)
		wide_editor.disable_node(wide_editor.left_leg_layer)
		
		slim_editor.disable_node(slim_editor.left_leg)
		slim_editor.disable_node(slim_editor.left_leg_layer)
		
		leg_left_button.texture_normal.region = Rect2(5, 0, 5, 13)
	else:
		if wide_editor.layer_enabled:
			wide_editor.enable_node(wide_editor.left_leg_layer)
			slim_editor.enable_node(slim_editor.left_leg_layer)
		
		wide_editor.enable_node(wide_editor.left_leg)
		slim_editor.enable_node(slim_editor.left_leg)
		
		leg_left_button.texture_normal.region = Rect2(0, 0, 5, 13)
	leg_left_enabled = not leg_left_enabled

func _on_head_pressed() -> void:
	if head_enabled:
		wide_editor.disable_node(wide_editor.head)
		wide_editor.disable_node(wide_editor.head_layer)
		
		slim_editor.disable_node(slim_editor.head)
		slim_editor.disable_node(slim_editor.head_layer)
		
		head_button.texture_normal.region = Rect2(10, 0, 10, 11)
	else:
		if wide_editor.layer_enabled:
			wide_editor.enable_node(wide_editor.head_layer)
			slim_editor.enable_node(slim_editor.head_layer)
		
		wide_editor.enable_node(wide_editor.head)
		slim_editor.enable_node(slim_editor.head)
		
		head_button.texture_normal.region = Rect2(0, 0, 10, 11)
	head_enabled = not head_enabled


func _on_layer_check_button_toggled(toggled_on: bool) -> void:
	wide_editor.layer_enabled = toggled_on
	if toggled_on:
		if head_enabled:
			wide_editor.enable_node(wide_editor.head_layer)
			slim_editor.enable_node(slim_editor.head_layer)
		if body_enabled:
			wide_editor.enable_node(wide_editor.body_layer)
			slim_editor.enable_node(slim_editor.body_layer)
		if arm_left_enabled:
			wide_editor.enable_node(wide_editor.left_arm_layer)
			slim_editor.enable_node(slim_editor.left_arm_layer)
		if leg_left_enabled:
			wide_editor.enable_node(wide_editor.left_leg_layer)
			slim_editor.enable_node(slim_editor.left_leg_layer)
		if arm_right_enabled:
			wide_editor.enable_node(wide_editor.right_arm_layer)
			slim_editor.enable_node(slim_editor.right_arm_layer)
		if leg_right_enabled:
			wide_editor.enable_node(wide_editor.right_leg_layer)
			slim_editor.enable_node(slim_editor.right_leg_layer)
	else:
		wide_editor.disable_node(wide_editor.head_layer)
		wide_editor.disable_node(wide_editor.body_layer)
		wide_editor.disable_node(wide_editor.left_arm_layer)
		wide_editor.disable_node(wide_editor.left_leg_layer)
		wide_editor.disable_node(wide_editor.right_arm_layer)
		wide_editor.disable_node(wide_editor.right_leg_layer)
		
		slim_editor.disable_node(slim_editor.head_layer)
		slim_editor.disable_node(slim_editor.body_layer)
		slim_editor.disable_node(slim_editor.left_arm_layer)
		slim_editor.disable_node(slim_editor.left_leg_layer)
		slim_editor.disable_node(slim_editor.right_arm_layer)
		slim_editor.disable_node(slim_editor.right_leg_layer)
		


func _on_model_selector_item_selected(index: int) -> void:
	match index:
		0: # Wide
			wide_editor.enable()
			slim_editor.disable()
		1: # Slim
			wide_editor.disable()
			slim_editor.enable()
