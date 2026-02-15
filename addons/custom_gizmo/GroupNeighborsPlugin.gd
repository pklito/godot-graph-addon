@tool
extends EditorPlugin


var _btn: Button
var _btn_remove: Button


func _enter_tree() -> void:
	EditorInterface.get_selection().selection_changed.connect(_selection_changed)
	_btn = Button.new()
	_btn.text = "CONNECT"

	_btn.pressed.connect(_on_pressed)
	
	_btn_remove = Button.new()
	_btn_remove.text = "DISCONNECT"
	_btn_remove.pressed.connect(_on_pressed_disconnect)
	
	var small_font_size := 11
	for b in [_btn, _btn_remove]:
		b.flat = true
		b.custom_minimum_size = Vector2(80, 20)
		b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		b.add_theme_font_size_override("font_size", small_font_size)

	# Adds to the main editor toolbar.
	add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU, _btn)
	add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU, _btn_remove)


func _exit_tree() -> void:
	EditorInterface.get_selection().selection_changed.disconnect(_selection_changed)
	
	if _btn:
		remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, _btn)
		_btn.queue_free()
		_btn = null
	if _btn_remove:
		remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, _btn_remove)
		_btn_remove.queue_free()
		_btn_remove = null


func _on_pressed() -> void:
	var selection := EditorInterface.get_selection()
	var nodes: Array = selection.get_selected_nodes()
	var is_location = func (x): return x is Location
	var location_nodes : Array = nodes.filter(is_location)
		
	if location_nodes.is_empty():
		printerr("Selection somehow doesn't have Location nodes")
		return
		
	for i in range(0,location_nodes.size()):
		for j in range(i,location_nodes.size()):
			var node_i : Location = location_nodes[i]
			var node_j : Location = location_nodes[j]
			if node_i not in node_j.neighbors:
				node_j.neighbors.append(node_i)
			if node_j not in node_i.neighbors:
				node_i.neighbors.append(node_j)
	
	

		
func _on_pressed_disconnect() -> void:
	var selection := EditorInterface.get_selection()
	var nodes: Array = selection.get_selected_nodes()
	var is_location = func (x): return x is Location
	var location_nodes : Array = nodes.filter(is_location)
		
	if location_nodes.is_empty():
		printerr("Selection somehow doesn't have Location nodes")
		return
	
	for i in range(0,location_nodes.size()):
		for j in range(i,location_nodes.size()):
			# Remove eachother as neighbors
			var node_i : Location = location_nodes[i]
			var node_j : Location = location_nodes[j]
			var j_loc = node_i.neighbors.find(node_j)
			var i_loc = node_j.neighbors.find(node_i)
			if j_loc != -1: node_i.neighbors.remove_at(j_loc)
			if i_loc != -1: node_j.neighbors.remove_at(i_loc)
			
			
		
		

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
	
