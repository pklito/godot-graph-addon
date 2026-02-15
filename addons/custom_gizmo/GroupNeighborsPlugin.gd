@tool
extends EditorPlugin


var _btn: Button
var _btn_remove: Button


func _enter_tree() -> void:
	EditorInterface.get_selection().selection_changed.connect(_selection_changed)
	_btn = Button.new()
	_btn.text = "Connect Neighbors"
	_btn.pressed.connect(_on_pressed)
	
	_btn_remove = Button.new()
	

	# Adds to the main editor toolbar.
	add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU, _btn)

	print("[Print Selection] Plugin loaded")

func _exit_tree() -> void:
	EditorSelection.selection_changed.disconnect(_selection_changed)
	
	if _btn:
		remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, _btn)
		_btn.queue_free()
		_btn = null

	print("[Print Selection] Plugin unloaded")

func _on_pressed() -> void:
	var selection := EditorInterface.get_selection()
	var nodes: Array = selection.get_selected_nodes()

	if nodes.is_empty():
		print("[Print Selection] (none)")
		return

	print("[Print Selection] Selected nodes (%d):" % nodes.size())
	for n in nodes:
		# name + full path is usually the most useful
		print(" - %s  (%s)" % [n.name, str(n.get_path())])

func _selection_changed():
	var nodes: Array = EditorInterface.get_selection().get_selected_nodes()
	for node in nodes:
		if node is Location:
			# if one found
			_btn.visible = true
			_btn_remove.visible = true
			return
	
	# if no location found
	_btn.visible = false
	_btn_remove.visible = false
	
