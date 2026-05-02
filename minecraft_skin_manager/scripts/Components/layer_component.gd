class_name LayerComponent extends Node

@export var skin_editor: TextureEditor

var layers: Array = []
var active_layer: int = 0

func _ready() -> void:
	ensure_at_least_one_layer()


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
	#skin_editor.refresh_texture()
	

func set_layer_opacity(i, value):
	layers[i]["opacity"] = clamp(value, 0.0, 1.0)
	#skin_editor.refresh_texture()
	

func move_layer_up(i):
	if i < layers.size() - 1:
		var tmp = layers[i]
		layers[i] = layers[i + 1]
		layers[i + 1] = tmp
		active_layer = i + 1
		#skin_editor.refresh_texture()

func move_layer_down(i):
	if i > 0:
		var tmp = layers[i]
		layers[i] = layers[i - 1]
		layers[i - 1] = tmp
		active_layer = i - 1
		#skin_editor.refresh_texture()


func merge_layer(i):
	var width: int = skin_editor.width
	var height: int = skin_editor.height
	
	if i == 0:
		return
	
	var top = layers[i]["image"]
	var bottom = layers[i - 1]["image"]
	
	for x in width:
		for y in height:
			var c = top.get_pixel(x, y)
			if c.a > 0.0:
				bottom.set_pixel(x, y, c)
	
	layers.remove_at(i)
	active_layer = i - 1
	#skin_editor.refresh_texture()
	

func create_layer(name := "Layer"):
	var width: int = skin_editor.width
	var height: int = skin_editor.height
	
	var img := Image.create(width, height, false, Image.FORMAT_RGBA8)
	img.fill(Color(0,0,0,0))
	
	layers.append({
		"name": name,
		"image": img,
		"visible": true,
		"opacity": 1.0
	})
	
	active_layer = layers.size() - 1
	#skin_editor.refresh_texture()


func delete_layer(index: int):
	if layers.size() <= 1:
		return # on ne supprime jamais le dernier calque
	
	layers.remove_at(index)
	
	# réajuster le calque actif
	active_layer = clamp(index - 1, 0, layers.size() - 1)
	
	#skin_editor.refresh_texture()
	

func set_active_layer(i: int):
	active_layer = clamp(i, 0, layers.size() - 1)
	

func toggle_layer_visibility(i):
	layers[i]["visible"] = !layers[i]["visible"]
	#skin_editor.refresh_texture()
	


func ensure_at_least_one_layer():
	if layers.is_empty():
		create_layer("Base")
