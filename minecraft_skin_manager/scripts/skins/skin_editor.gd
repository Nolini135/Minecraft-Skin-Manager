extends Node3D
class_name SkinEditorModel

var layer_enabled: bool = true

# Head
@onready var full_head: Node3D = $Waist/Head2
@onready var head: MeshInstance3D = $Waist/Head2/Head
@onready var head_layer: MeshInstance3D = $"Waist/Head2/Hat Layer"

# Body
@onready var full_body: Node3D = $Waist/Body2
@onready var body: MeshInstance3D = $Waist/Body2/Body
@onready var body_layer: MeshInstance3D = $"Waist/Body2/Body Layer"

# Right Arm
@onready var full_right_arm: Node3D = $"Waist/Right Arm2"
@onready var right_arm: MeshInstance3D = $"Waist/Right Arm2/Right Arm"
@onready var right_arm_layer: MeshInstance3D = $"Waist/Right Arm2/Right Arm Layer"

# Left Arm
@onready var full_left_arm: Node3D = $"Waist/Left Arm2"
@onready var left_arm: MeshInstance3D = $"Waist/Left Arm2/Left Arm"
@onready var left_arm_layer: MeshInstance3D = $"Waist/Left Arm2/Left Arm Layer"

# Right Leg
@onready var full_right_leg: Node3D = $"Right Leg2"
@onready var right_leg: MeshInstance3D = $"Right Leg2/Right Leg"
@onready var right_leg_layer: MeshInstance3D = $"Right Leg2/Right Leg Layer"

# Left Leg
@onready var full_left_leg: Node3D = $"Left Leg2"
@onready var left_leg: MeshInstance3D = $"Left Leg2/Left Leg"
@onready var left_leg_layer: MeshInstance3D = $"Left Leg2/Left Leg Layer"


######### Disable Nodes #########

func disable_node(node: Node):
	node.visible = false
	node.set_process(false)
	node.set_physics_process(false)
	node.set_process_input(false)
	
	for child in node.get_children():
		if child is CollisionObject3D:
			var shape = child.get_node("CollisionShape3D")
			shape.disabled = true
		disable_node(child)

func enable_node(node: Node):
	node.visible = true
	node.set_process(true)
	node.set_physics_process(true)
	node.set_process_input(true)
	
	for child in node.get_children():
		if child is CollisionObject3D:
			var shape = child.get_node("CollisionShape3D")
			shape.disabled = false
		enable_node(child)

func disable():
	visible = false
	for child in self.get_children():
		if child is CollisionObject3D:
			var shape = child.get_node("CollisionShape3D")
			shape.disabled = true

func enable():
	visible = true
	for child in self.get_children():
		if child is CollisionObject3D:
			var shape = child.get_node("CollisionShape3D")
			shape.disabled = false
