class_name LayerComponent extends Node

@export var skin_editor: TextureEditor

var layers: Array = []
var active_layer: int = 0

func add_layer(name := "Layer"):
	var img := Image.create(skin_editor.width, skin_editor.height, false, Image.FORMAT_RGBA8)
	img.fill(Color(0,0,0,0)) # transparent
	
	layers.append({
		"name": name,
		"image": img,
		"visible": true,
		"opacity": 1.0
	})
	
	active_layer = layers.size() - 1
	

func render_layers() -> Image:
	var width: int = skin_editor.width
	var height: int = skin_editor.height
	
	var final := Image.create(width, height, false, Image.FORMAT_RGBA8)
	final.fill(Color(0,0,0,0))
	
	for layer in layers:
		if not layer["visible"]:
			continue
	
		var img = layer["image"]
		var opacity = layer["opacity"]
	
		for x in width:
			for y in height:
				var c = img.get_pixel(x, y)
				if c.a > 0.0:
					# alpha blending
					var base = final.get_pixel(x, y)
					final.set_pixel(x, y, base.lerp(c, opacity))
	return final


func toggle_layer(i):
	layers[i]["visible"] = !layers[i]["visible"]
	skin_editor.refresh_texture()
	

func set_layer_opacity(i, value):
	layers[i]["opacity"] = clamp(value, 0.0, 1.0)
	skin_editor.refresh_texture()
	

func move_layer_up(i):
	if i < layers.size() - 1:
		#layers.swap(i, i + 1)
		active_layer = i + 1
		skin_editor.refresh_texture()

func move_layer_down(i):
	if i > 0:
		#layers.swap(i, i - 1)
		active_layer = i - 1
		skin_editor.refresh_texture()
