extends Node3D
class_name SkinEditorModel

enum Part { HEAD, BODY, RIGHT_ARM, LEFT_ARM, RIGHT_LEG, LEFT_LEG }

## État des layers (hat, jacket, manches...). Une seule source de vérité : ce modèle.
var layer_enabled: bool = true

# Part -> bool. Rempli dans _ready().
var _part_enabled: Dictionary = {}
var _layer_enabled: Dictionary = {}
# Part -> [mesh de base, mesh du layer]. Rempli dans _ready().
var _parts: Dictionary = {}

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


func _ready() -> void:
	_parts = {
		Part.HEAD: [head, head_layer],
		Part.BODY: [body, body_layer],
		Part.RIGHT_ARM: [right_arm, right_arm_layer],
		Part.LEFT_ARM: [left_arm, left_arm_layer],
		Part.RIGHT_LEG: [right_leg, right_leg_layer],
		Part.LEFT_LEG: [left_leg, left_leg_layer],
	}
	for part in _parts:
		_part_enabled[part] = true
		_layer_enabled[part] = true
	
	refresh_collisions()


######### Parties du corps #########

func is_part_enabled(part: Part) -> bool:
	return _part_enabled[part]


func set_part_enabled(part: Part, enabled: bool) -> void:
	_part_enabled[part] = enabled
	_apply_part(part)
	refresh_collisions()


######### Layers #########

func is_part_layer_enabled(part: Part) -> bool:
	return _layer_enabled[part]


func set_part_layer_enabled(part: Part, enabled: bool) -> void:
	_layer_enabled[part] = enabled
	_apply_part(part)
	refresh_collisions()


## Active/désactive tous les layers d'un coup (bouton global)
func set_layer_enabled(enabled: bool) -> void:
	for part in _parts:
		_layer_enabled[part] = enabled
		_apply_part(part)
	refresh_collisions()


######### Modèle entier (wide / slim) #########

func enable() -> void:
	visible = true
	refresh_collisions()


func disable() -> void:
	visible = false
	refresh_collisions()


######### Interne #########

# Un layer n'est visible que si sa partie est active ET que les layers sont activés.
func _apply_part(part: Part) -> void:
	var meshes: Array = _parts[part]
	var on: bool = _part_enabled[part]
	meshes[0].visible = on
	meshes[1].visible = on and _layer_enabled[part]


## Les colliders suivent la visibilité réelle dans l'arbre : un nœud caché, ou dont
## un parent est caché (ex. le modèle slim quand le wide est affiché), n'est jamais
## détectable par un raycast.
func refresh_collisions() -> void:
	for shape in find_children("*", "CollisionShape3D", true, false):
		shape.set_deferred("disabled", not shape.is_visible_in_tree())
