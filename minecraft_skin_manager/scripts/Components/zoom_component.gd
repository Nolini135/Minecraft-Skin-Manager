class_name CanvasViewerComponent extends Node

@export var skin_editor: TextureEditor
@export var tool_component: ToolComponent
@export var undo_component: UndoComponent

@onready var canvas_viewer: Control = %CanvasViewer
@onready var zoom_container: Control = %ZoomContainer
@onready var canvas: TextureRect = %Canvas


# Canvas Viewer Variables
var zoom: float = 1.0
var offset: Vector2 = Vector2.ZERO
var dragging: bool = false
var drag_start: Vector2 = Vector2.ZERO
var offset_start: Vector2 = Vector2.ZERO
var is_mouse_on_canvas: bool = false
var is_mouse_on_skin_viewer: bool = false


func _input(event: InputEvent) -> void:
	# save undo states when start clicking
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if is_mouse_on_canvas or is_mouse_on_skin_viewer:
				undo_component.push_undo_state()
				tool_component.is_painting = true
			else:
				tool_component.is_painting = false
	
	zoom_canvas(event)


func zoom_canvas(event: InputEvent):
	if event is InputEventMouseButton and is_mouse_on_canvas:
		var mouse_pos = canvas_viewer.get_local_mouse_position()
		var content_pos = (mouse_pos - offset) / zoom
		
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom *= 1.1
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom /= 1.1
		
		zoom = clamp(zoom, 0.1, 10.0)
		offset = mouse_pos - content_pos * zoom
		update_canvas_viewer()
	
	if event is InputEventMouseButton and is_mouse_on_canvas:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			dragging = event.pressed
			if dragging:
				drag_start = get_viewport().get_mouse_position()
				offset_start = offset
	if event is InputEventMouseMotion and dragging:
		var delta = get_viewport().get_mouse_position() - drag_start
		offset = offset_start + delta
		
		update_canvas_viewer()
	


############# Canvas Hovered ? ###################

func _on_canvas_viewer_mouse_entered() -> void:
	is_mouse_on_canvas = true

func _on_canvas_viewer_mouse_exited() -> void:
	is_mouse_on_canvas = false

############### 3D Editor Hovered ? ##################

func _on_sub_viewport_container_mouse_entered() -> void:
	is_mouse_on_skin_viewer = true

func _on_sub_viewport_container_mouse_exited() -> void:
	is_mouse_on_skin_viewer = false


func update_canvas_viewer():
	zoom_container.scale = Vector2(zoom, zoom)
	zoom_container.position = offset


func _on_center_button_pressed() -> void:
	offset = Vector2.ZERO
	update_canvas_viewer()
