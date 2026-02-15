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

func _update_gizmo_neighbors(i_on_j_action: Callable, action_name: String) -> void:
	var nodes: Array = EditorInterface.get_selection().get_selected_nodes()
	
	var location_nodes : Array[Location] = []
	location_nodes.assign(nodes.filter(func (x): return x is Location))


	if location_nodes.is_empty():
		push_warning("No Location nodes selected")
		return
	if location_nodes.size() <= 1:
		push_warning("Select at least 2 Location nodes")
		return

	var before: Array[Array] = []
	var after: Array[Array] = []
	for loc in location_nodes:
		before.append(loc.neighbors.duplicate(true))
		after.append(loc.neighbors.duplicate(true))

	# Apply edits to "after" only (not the live nodes)
	for i in range(location_nodes.size()):
		for j in range(i + 1, location_nodes.size()):
			i_on_j_action.call(after, location_nodes, i, j)
			i_on_j_action.call(after, location_nodes, j, i)

	var ur := get_undo_redo()
	ur.create_action(action_name)

	for i in range(location_nodes.size()):
		ur.add_do_property(location_nodes[i], "neighbors", after[i].duplicate(true))
		ur.add_undo_property(location_nodes[i], "neighbors", before[i].duplicate(true))

		ur.add_do_method(location_nodes[i], "update_gizmos")
		ur.add_undo_method(location_nodes[i], "update_gizmos")

	ur.commit_action()


func _on_pressed() -> void:
	var action := func(output_array: Array[Array], location_nodes: Array[Location], i: int, j: int) -> void:
		var node_i: Location = location_nodes[i]
		var node_j: Location = location_nodes[j]
		if node_i == node_j:
			return
		if output_array[j].find(node_i) == -1:
			output_array[j].append(node_i)

	_update_gizmo_neighbors(action, "Connect Neighbors")


func _on_pressed_disconnect() -> void:
	var action := func(output_array: Array[Array], location_nodes: Array[Location], i: int, j: int) -> void:
		var node_i: Location = location_nodes[i]
		var node_j: Location = location_nodes[j]
		if node_i == node_j:
			return
		var idx := output_array[i].find(node_j)
		if idx != -1:
			output_array[i].remove_at(idx)

	_update_gizmo_neighbors(action, "Disconnect Neighbors")

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
	
