extends ConfirmationDialog

signal skin_ready(image: Image)

@export var editor: TextureEditor

#Panel References
@onready var template_panel: Panel = $Panel/MarginContainer/VBoxContainer/TemplatePanel
@onready var solid_color_panel: Panel = $Panel/MarginContainer/VBoxContainer/SolidColorPanel
@onready var empty_cavas_panel: Panel = $Panel/MarginContainer/VBoxContainer/EmptyCavasPanel
@onready var get_from_user_panel: Panel = $Panel/MarginContainer/VBoxContainer/GetFromUserPanel


#Http request
@onready var http: HTTPRequest = HTTPRequest.new()

#Options
@onready var canvas_option: OptionButton = $Panel/MarginContainer/VBoxContainer/CavasOption/OptionButton
@onready var canvas_size: OptionButton = $Panel/MarginContainer/VBoxContainer/CanvasSizeOption/OptionButton
@onready var skin_model: OptionButton = $Panel/MarginContainer/VBoxContainer/SkinModelOption/OptionButton

#Template Options
@onready var template_option: OptionButton = $Panel/MarginContainer/VBoxContainer/TemplatePanel/MarginContainer/VBoxContainer/OptionButton

#Solid Color Options
@onready var solid_color_option: ColorPickerButton = $Panel/MarginContainer/VBoxContainer/SolidColorPanel/MarginContainer/VBoxContainer/Color/ColorPickerButton

#From Username Options
@onready var username_input: LineEdit = $Panel/MarginContainer/VBoxContainer/GetFromUserPanel/MarginContainer/VBoxContainer/UsernameInput



#For HTTP Request
var step = 0
var current_username = ""
var current_uuid = ""

#For panel switching
var previous_panel: Panel

func _ready():
	previous_panel = template_panel
	add_child(http)
	http.request_completed.connect(_on_request_completed)
	self.skin_ready.connect(_on_skin_ready)


func _on_confirmed() -> void:
	var image: Image
	
	match canvas_option.selected:
		0: #skin template
			image = create_skin_template()
		1: #solid color
			image = create_solid_color()
		2: #empty canvas
			image = create_empty_image()
		3: #from username
			if username_input.text:
				image = get_skin(username_input.text)
			else:
				image = get_skin("Steve")
	
	if image:
		editor.initialize_canvas(image)

func _on_option_button_item_selected(index: int) -> void:
	match index:
		0:
			previous_panel.hide()
			template_panel.show()
			previous_panel = template_panel
		1:
			previous_panel.hide()
			solid_color_panel.show()
			previous_panel = solid_color_panel
		2:
			previous_panel.hide()
			empty_cavas_panel.show()
			previous_panel = empty_cavas_panel
		3:
			previous_panel.hide()
			get_from_user_panel.show()
			previous_panel = get_from_user_panel


func create_skin_template() -> Image:
	var size = 64 if canvas_size.selected == 0 else 128
	var model = "wide" if skin_model.selected == 0 else "slim"
	var names := ["Alex", "Ari", "Efe", "Kai", "Makena", "Noor", "Steve", "Sunny", "Zuri"]
	var name = names[template_option.selected]
	var path := "res://default skins/%s/%s%s.png" % [
		model,
		name,
		"HD" if size == 128 else ""
	]
	
	var tex = load(path)
	return tex.get_image().duplicate()

func create_solid_color() -> Image:
	var size = 64 if canvas_size.selected == 0 else 128
	var image: Image
	
	image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(solid_color_option.color)
	return image

func create_empty_image() -> Image:
	var size = 64 if canvas_size.selected == 0 else 128
	var image: Image
	
	image = Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.0, 0.0, 0.0, 0.0))
	return image

func get_skin(username: String):
	current_username = username
	step = 1
	http.request("https://api.mojang.com/users/profiles/minecraft/%s" % username)
	print("request send")


func _on_skin_ready(skin: Image):
	var size = 64 if canvas_size.selected == 0 else 128
	
	var img: Image = skin
	
	if size == 128:
		img = upscale_64_to_128(skin)
	
	editor.initialize_canvas(img)

func _on_request_completed(result, code, headers, body):
	if step == 1:
		if code != 200:
			print("Pseudo introuvable")
			return
		print("request step 1")
	
		var json = JSON.parse_string(body.get_string_from_utf8())
		current_uuid = json["id"]
	
		step = 2
		http.request("https://sessionserver.mojang.com/session/minecraft/profile/%s" % current_uuid)
	
	elif step == 2:
		var json = JSON.parse_string(body.get_string_from_utf8())
		var b64 = json["properties"][0]["value"]
		var decoded = Marshalls.base64_to_utf8(b64)
		var tex_json = JSON.parse_string(decoded)
	
		var skin_url = tex_json["textures"]["SKIN"]["url"]
		print("skin url: ", skin_url)
	
		step = 3
		http.request(skin_url)
		print("request step 2")
	
	elif step == 3:
		var img = Image.new()
		img.load_png_from_buffer(body)
		var tex = ImageTexture.create_from_image(img)
		print("request step 3")
		emit_signal("skin_ready", img)
		
	

func upscale_64_to_128(img: Image) -> Image:
	var new_img: Image = img.duplicate()
	new_img.resize(128, 128, Image.INTERPOLATE_NEAREST)
	return new_img
