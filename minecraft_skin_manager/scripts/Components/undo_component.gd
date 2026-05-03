class_name UndoComponent extends Node

@export var skin_editor: TextureEditor

# undo/redo CRTL+Z CRTL+Y
var undo_stack: Array[Image] = []
var redo_stack: Array[Image] = []

func undo():
	var image = skin_editor.image
	
	if undo_stack.is_empty():
		return
	redo_stack.append(image.duplicate())
	skin_editor.image = undo_stack.pop_back()
	skin_editor.refresh_texture()

func redo():
	var image = skin_editor.image
	
	if redo_stack.is_empty():
		return
	
	undo_stack.append(image.duplicate())
	skin_editor.image = redo_stack.pop_back()
	skin_editor.refresh_texture()


func push_undo_state():
	var image = skin_editor.image
	
	undo_stack.append(image.duplicate())
	redo_stack.clear()
	


func _on_undo_button_pressed() -> void:
	undo()

func _on_redo_button_pressed() -> void:
	redo()
