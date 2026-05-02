extends Control
class_name TextureEditor

@export_category("References")
@export var layer_component: LayerComponent

@onready var color_picker: ColorPicker = $VBoxContainer/HBoxContainer/ColorPanel/VBoxContainer/ColorPicker
@onready var tool_selector: OptionButton = $VBoxContainer/ToolsPanel/MarginContainer/VBoxContainer/HBoxContainer/ToolSelector
@onready var canvas: TextureRect = $VBoxContainer/HBoxContainer/HSplitContainer/VSplitContainer/CanvasPanel/MarginContainer/CanvasViewer/Control/ZoomContainer/Canvas
@onready var grid_overlay: Control = $VBoxContainer/HBoxContainer/HSplitContainer/VSplitContainer/CanvasPanel/MarginContainer/CanvasViewer/Control/GridOverlay
@onready var zoom_container: Control = $VBoxContainer/HBoxContainer/HSplitContainer/VSplitContainer/CanvasPanel/MarginContainer/CanvasViewer/Control/ZoomContainer
@onready var canvas_viewer: Control = $VBoxContainer/HBoxContainer/HSplitContainer/VSplitContainer/CanvasPanel/MarginContainer/CanvasViewer
@onready var skin_viewer: SkinEditorViewer = $"VBoxContainer/HBoxContainer/HSplitContainer/3DCanvasPanel/MarginContainer/SubViewportContainer"

@onready var file_menu: PopupMenu = $VBoxContainer/ToolsPanel/MarginContainer/VBoxContainer/MenuBar/FileMenu

@onready var new_skin_confirmation_dialog: ConfirmationDialog = $Windows/NewSkinConfirmationDialog
@onready var open_file_dialog: FileDialog = $OpenFileDialog
@onready var save_file_dialog: FileDialog = $SaveFileDialog


var selected_color: Color = Color("ff0000ff")
var hex: String = "#ff0000"

var selected_tool: String = "pen"

@export_category("Tools")
@export var hold_click_tools: Array[String]
@export var single_click_tools: Array[String]

var image: Image
var texture: ImageTexture
var width: int = 0
var height: int = 0

# Canvas Viewer Variables
var zoom: float = 1.0
var offset: Vector2 = Vector2.ZERO
var dragging: bool = false
var drag_start: Vector2 = Vector2.ZERO
var offset_start: Vector2 = Vector2.ZERO
var is_mouse_on_canvas: bool = false

# undo/redo CRTL+Z CRTL+Y
var undo_stack: Array[Image] = []
var redo_stack: Array[Image] = []

var is_painting: bool = false
var is_mouse_on_skin_viewer: bool = false

# dynamic color picker
var is_holding_alt: bool = true
var old_tool: String

func _ready():
	zoom_container.size_flags_stretch_ratio = true
	
	var img = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color(1.0, 1.0, 1.0, 1.0))
	
	initialize_canvas(img)

func _on_color_picker_color_changed(color: Color) -> void:
	# Color (RGBA)
	selected_color = color_picker.color
	
	# html / hex
	if selected_color.a < 1.0:
		hex = selected_color.to_html(true)
	else:
		hex = selected_color.to_html(false)
	

func _input(event: InputEvent) -> void:
	zoom_canvas(event)
	
	# save undo states when start clicking
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			if is_mouse_on_canvas or is_mouse_on_skin_viewer:
				push_undo_state()
				is_painting = true
			else:
				is_painting = false
	
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
	
	# Dynamic color picker
	if Input.is_action_just_pressed("dynamic_picker"):
		old_tool = selected_tool
		is_holding_alt = true
		selected_tool = "color_picker"
	elif Input.is_action_just_released("dynamic_picker"):
		selected_tool = old_tool
		is_holding_alt = false

# Tool selector
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

############################ Texture Editor ############################

func initialize_canvas(img: Image):
	image = img
	texture = ImageTexture.create_from_image(image)
	
	canvas.texture = texture
	
	width = texture.get_width()
	height = texture.get_height()
	update_preview()
	
	print(width)

func change_image(img):
	var image: Image
	
	if img is Texture2D:
		image = img.get_image()
	elif img is Image:
		image = img
	else:
		push_error("change_image: unsupported type: %s" % img)
		return
	
	# Toujours créer une texture indépendante
	texture = ImageTexture.create_from_image(image)
	
	canvas.texture = texture
	
	width = texture.get_width()
	height = texture.get_height()
	update_preview()

func update_preview():
	skin_viewer.apply_skin_to_model(skin_viewer.skin_wide, texture)
	skin_viewer.apply_skin_to_model(skin_viewer.skin_slim, texture)

func _on_canvas_gui_input(event: InputEvent) -> void:
	var local_pos = event.position
	var pixel = local_to_image(local_pos)
	
	if event is InputEventMouseMotion and Input.is_action_pressed("left_click"):
		if hold_click_tools.has(selected_tool):
			draw_action(selected_tool, pixel)
			
	elif event is InputEventMouseButton and Input.is_action_just_pressed("left_click"):
		if single_click_tools.has(selected_tool):
			draw_action(selected_tool, pixel)

func draw_from_uv(uv: Vector2):
	var tex_size = texture.get_size()
	

	var pos = Vector2i(
		floor(uv.x * tex_size.x),
		floor(uv.y * tex_size.x)
	)
	draw_action(selected_tool, pos)

func draw_action(tool: String, pos: Vector2i):
	match tool:
		"pen":
			draw_pixel(pos)
		"eraser":
			erase_pixel(pos)
		"bucket":
			bucket_fill(pos)
		"color_picker":
			color_picker_tool(pos)

func local_to_image(pos: Vector2):
	var tex_size = texture.get_size()
	var rect_size = canvas.size
	var scale = tex_size / rect_size
	return Vector2i(pos.x * scale.x, pos.y * scale.y)

############################ Tools ############################

func draw_pixel(p: Vector2i):
	if is_in_bounds(p.x, p.y):
		#image.set_pixel(p.x, p.y, selected_color)
		var active_layer = layer_component.active_layer
		layer_component.layers[active_layer]["image"].set_pixel(p.x, p.y, selected_color)
		refresh_texture()

func erase_pixel(p: Vector2i):
	if is_in_bounds(p.x, p.y):
		#image.set_pixel(p.x, p.y, Color(0.0, 0.0, 0.0, 0.0))
		var active_layer = layer_component.active_layer
		layer_component.layers[active_layer]["image"].set_pixel(p.x, p.y, Color(0.0, 0.0, 0.0, 0.0))
		refresh_texture()

func color_picker_tool(p: Vector2i):
	if is_in_bounds(p.x, p.y):
		color_picker.color = image.get_pixel(p.x, p.y)
		selected_color = color_picker.color

func bucket_fill(start: Vector2i):
	var active_layer = layer_component.active_layer
	var img = layer_component.layers[active_layer]["image"]
	
	var w = img.get_width()
	var h = img.get_height()
	
	if start.x < 0 or start.y < 0 or start.x >= w or start.y >= h:
		return
	
	# Couleur d'origine
	var target_color = img.get_pixel(start.x, start.y)

	# Si la couleur est déjà celle qu'on veut mettre → rien à faire
	if target_color == selected_color:
		return

	# File pour BFS
	var queue: Array[Vector2i] = []
	queue.append(start)

	while queue.size() > 0:
		var p = queue.pop_back()

		# Vérification des limites
		if p.x < 0 or p.y < 0 or p.x >= w or p.y >= h:
			continue

		# Si ce pixel n'a pas la couleur d'origine → on ignore
		if img.get_pixel(p.x, p.y) != target_color:
			continue

		# On remplit le pixel
		img.set_pixel(p.x, p.y, selected_color)

		# On ajoute les voisins
		queue.append(Vector2i(p.x + 1, p.y))
		queue.append(Vector2i(p.x - 1, p.y))
		queue.append(Vector2i(p.x, p.y + 1))
		queue.append(Vector2i(p.x, p.y - 1))
	
	refresh_texture()



func is_in_bounds(x, y):
	if x < 0 or y < 0:
		return false
	if x >= image.get_width() or y >= image.get_height():
		return false
	return true

func update_texture():
	texture.update(image)
	update_preview()




func _on_open_file_dialog_file_selected(path: String) -> void:
	image = Image.load_from_file(path)
	update_texture()
	


func _on_file_saved(path: String) -> void:
	var img := texture.get_image()  # ton image de skin
	var err := img.save_png(path)
	
	if not err == OK:
		print("Erreur de sauvegarde :", err)


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
	


func update_canvas_viewer():
	zoom_container.scale = Vector2(zoom, zoom)
	zoom_container.position = offset






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


############## Undo / Redo ##############

func undo():
	
	if undo_stack.is_empty():
		return
	redo_stack.append(image.duplicate())
	image = undo_stack.pop_back()
	refresh_texture()

func redo():
	if redo_stack.is_empty():
		return
	
	undo_stack.append(image.duplicate())
	image = redo_stack.pop_back()
	refresh_texture()


func push_undo_state():
	undo_stack.append(image.duplicate())
	redo_stack.clear()

func refresh_texture():
	var final_render = layer_component.render_layers()
	texture = ImageTexture.create_from_image(final_render)
	canvas.texture = texture
	update_preview()


func _on_undo_button_pressed() -> void:
	undo()

func _on_redo_button_pressed() -> void:
	redo()
