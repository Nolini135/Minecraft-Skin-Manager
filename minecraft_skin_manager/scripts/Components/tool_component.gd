class_name ToolComponent extends Node

@export var skin_editor: TextureEditor
@export var canvas_viewer_component: CanvasViewerComponent

@onready var tool_selector: OptionButton = %ToolSelector


var is_painting: bool = false

# dynamic color picker
var is_holding_alt: bool = true
var old_tool: String

var selected_tool: String = "pen"

@export_category("Tools")
@export var hold_click_tools: Array[String]
@export var single_click_tools: Array[String]
@export var cursor_image: Dictionary[String, CompressedTexture2D]
@export var cursor_hotspot: Dictionary[String, Vector2i]



func _input(event: InputEvent) -> void:
	update_cursor()
	
	# Dynamic color picker
	if Input.is_action_just_pressed("dynamic_picker"):
		old_tool = selected_tool
		is_holding_alt = true
		selected_tool = "color_picker"
	elif Input.is_action_just_released("dynamic_picker"):
		selected_tool = old_tool
		is_holding_alt = false
	
	
		# Shortcuts for tools
	if event.is_action("shortcut_pen"):
		selected_tool = "pen"
		tool_selector.select(0)
	elif event.is_action("shortcut_eraser"):
		selected_tool = "eraser"
		tool_selector.select(1)
	elif event.is_action("shortcut_picker"):
		selected_tool = "color_picker"
		tool_selector.select(2)
	elif event.is_action("shortcut_bucket"):
		selected_tool = "bucket"
		tool_selector.select(3)
	
	# Dynamic color picker (Press/Release ALT)
	if Input.is_action_just_pressed("dynamic_picker"):
		old_tool = selected_tool
		is_holding_alt = true
		selected_tool = "color_picker"
	elif Input.is_action_just_released("dynamic_picker"):
		selected_tool = old_tool
		is_holding_alt = false

# Tool selector Options
func _on_tool_selector_item_selected(index: int) -> void:
	match index:
		0:
			selected_tool = "pen"
		1:
			selected_tool = "eraser"
		2:
			selected_tool = "color_picker"
		3:
			selected_tool = "bucket"



func _on_canvas_gui_input(event: InputEvent) -> void:
	var local_pos = event.position
	var pixel = skin_editor.local_to_image(local_pos)
	
	if event is InputEventMouseMotion and Input.is_action_pressed("left_click"):
		if hold_click_tools.has(selected_tool):
			skin_editor.draw_action(selected_tool, pixel)
			
	elif event is InputEventMouseButton and Input.is_action_just_pressed("left_click"):
		if single_click_tools.has(selected_tool):
			skin_editor.draw_action(selected_tool, pixel)


func update_cursor():
	var image = cursor_image.get(selected_tool)
	var hotspot = cursor_hotspot.get(selected_tool)
	
	if canvas_viewer_component.is_mouse_on_canvas or canvas_viewer_component.is_mouse_on_skin_viewer:
		Input.set_custom_mouse_cursor(image, Input.CURSOR_ARROW, hotspot)
	else:
		Input.set_custom_mouse_cursor(null)



func _on_color_picker_color_changed(color: Color) -> void:
	# Color (RGBA)
	skin_editor.selected_color = color
	
	# html / hex
	if color.a < 1.0:
		skin_editor.hex = color.to_html(true)
	else:
		skin_editor.hex = color.to_html(false)
