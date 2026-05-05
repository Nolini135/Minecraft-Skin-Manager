extends MenuBar

@export var editor: TextureEditor

@onready var file_menu: PopupMenu = $FileMenu
@onready var about_menu: PopupMenu = $AboutMenu

@onready var about_window: Window = %AboutWindow


func _on_file_menu_index_pressed(index: int) -> void:
	var idx = file_menu.get_item_id(index)
	match idx:
		1:
			editor.open_file_dialog.popup()
		2:
			editor.save_file_dialog.popup()
		3:
			editor.new_skin_confirmation_dialog.popup()


func _on_about_menu_about_to_popup() -> void:
	about_window.popup()
