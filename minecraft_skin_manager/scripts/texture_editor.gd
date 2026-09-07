extends Control
class_name TextureEditor

@export_category("References")
@export var layer_component: LayerComponent

@onready var color_picker: ColorPicker = %ColorPicker

@onready var tool_selector: OptionButton = %ToolSelector

@onready var canvas: TextureRect = %Canvas
@onready var grid_overlay: Control = %GridOverlay
@onready var zoom_container: Control = %ZoomContainer
@onready var canvas_viewer: Control = %CanvasViewer

@onready var skin_viewer: SkinEditorViewer = %SubViewportContainer

@onready var file_menu: PopupMenu = %FileMenu

@onready var new_skin_confirmation_dialog: ConfirmationDialog = %NewSkinConfirmationDialog
@onready var open_file_dialog: FileDialog = $OpenFileDialog
@onready var save_file_dialog: FileDialog = $SaveFileDialog

@onready var tool_component: ToolComponent = %ToolComponent

var selected_color: Color = Color("ff0000ff")
var hex: String = "#ff0000"


var image: Image
var texture: ImageTexture
var width: int = 0
var height: int = 0


var is_ready: bool = false

func _ready():
	get_window().min_size = Vector2(1150, 700)
	
	zoom_container.size_flags_stretch_ratio = true
	
	var img = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	img.fill(Color(1.0, 1.0, 1.0, 1.0))
	
	initialize_canvas(img)
	is_ready = true


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


func draw_from_uv(uv: Vector2):
	if uv == null:
		return
	if not (is_finite(uv.x) and is_finite(uv.y)):
		return
	
	var tex_size = texture.get_size()
	
	var pos = Vector2i(
		floor(clamp(uv.x, 0.0, 0.999999) * tex_size.x),
		floor(clamp(uv.y, 0.0, 0.999999) * tex_size.y)
	)
	draw_action(tool_component.selected_tool, pos)

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
		image.set_pixel(p.x, p.y, selected_color)
		#var active_layer = layer_component.active_layer
		#layer_component.layers[active_layer]["image"].set_pixel(p.x, p.y, selected_color)
		refresh_texture()

func erase_pixel(p: Vector2i):
	if is_in_bounds(p.x, p.y):
		image.set_pixel(p.x, p.y, Color(0.0, 0.0, 0.0, 0.0))
		#var active_layer = layer_component.active_layer
		#layer_component.layers[active_layer]["image"].set_pixel(p.x, p.y, Color(0.0, 0.0, 0.0, 0.0))
		refresh_texture()

func color_picker_tool(p: Vector2i):
	if is_in_bounds(p.x, p.y):
		color_picker.color = image.get_pixel(p.x, p.y)
		selected_color = color_picker.color

func bucket_fill(start: Vector2i):
	#var active_layer = layer_component.active_layer
	#var img = layer_component.layers[active_layer]["image"]
	
	var img = image
	
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

func fill_face_from_uv_rect(uv_min: Vector2, uv_max: Vector2):
	if not (is_finite(uv_min.x) and is_finite(uv_min.y) and is_finite(uv_max.x) and is_finite(uv_max.y)):
		return
	
	var tex_size = texture.get_size()
	var px_min = Vector2i(round(uv_min.x * tex_size.x), round(uv_min.y * tex_size.y))
	var px_max = Vector2i(round(uv_max.x * tex_size.x), round(uv_max.y * tex_size.y))
	
	for x in range(px_min.x, px_max.x):
		for y in range(px_min.y, px_max.y):
			if is_in_bounds(x, y):
				image.set_pixel(x, y, selected_color)
	
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


func refresh_texture():
	if canvas == null:
		printerr("canvas is null, skipping refresh")
		return
	
	#var final_render = layer_component.render_layers()
	#texture = ImageTexture.create_from_image(final_render)
	texture = ImageTexture.create_from_image(image)
	canvas.texture = texture
	update_preview()
