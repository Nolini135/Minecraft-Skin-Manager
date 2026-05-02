extends ConfirmationDialog

@export var editor: TextureEditor

#Options
@onready var canvas_option: OptionButton = $Panel/MarginContainer/VBoxContainer/CavasOption/OptionButton
@onready var canvas_size: OptionButton = $Panel/MarginContainer/VBoxContainer/CanvasSizeOption/OptionButton
@onready var skin_model: OptionButton = $Panel/MarginContainer/VBoxContainer/SkinModelOption/OptionButton

#Template Options
@onready var template_option: OptionButton = $Panel/MarginContainer/VBoxContainer/TemplatePanel/MarginContainer/VBoxContainer/OptionButton

#Solid Color Options
@onready var solid_color_option: ColorPickerButton = $Panel/MarginContainer/VBoxContainer/SolidColorPanel/MarginContainer/VBoxContainer/Color/ColorPickerButton


func _on_confirmed() -> void:
	var image: Image
	
	match canvas_option.selected:
		0: #skin template
			image = create_skin_template()
		1: #solid color
			image = create_solid_color()
		2: #empty canvas
			image = create_empty_image()
	
	if image:
		editor.initialize_canvas(image)


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
	var image: Image
	
	image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color(1.0, 1.0, 1.0, 1.0))
	return image

func create_empty_image() -> Image:
	var image: Image
	
	image = Image.create(64, 64, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.0, 0.0, 0.0, 0.0))
	return image
