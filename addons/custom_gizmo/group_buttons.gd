@tool
extends EditorPlugin

var _btn: Button
var _btn_remove: Button
var _btn_new: Button

var _buttons: Array[Button] = []

func _enter_tree():
	EditorInterface.get_selection().selection_changed.connect(_selection_changed)
	_btn = Button.new()
	_btn.text = "CONNECT"

	_btn.pressed.connect(_on_pressed)
	
	_btn_remove = Button.new()
	_btn_remove.text = "DISCONNECT"
	_btn_remove.pressed.connect(_on_pressed_disconnect)
	
	_btn_new = Button.new()
	_btn_new.text = "NEW"
	_btn_new.pressed.connect(_on_pressed_new)
	_buttons = [_btn, _btn_remove, _btn_new]
	var small_font_size := 11
	for b in _buttons:
		b.flat = true
		b.custom_minimum_size = Vector2(80, 20)
		b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		b.add_theme_font_size_override("font_size", small_font_size)

	# Adds to the main editor toolbar.
	add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU, _btn)
	add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU, _btn_remove)
	add_control_to_container(CONTAINER_SPATIAL_EDITOR_MENU, _btn_new)


func _exit_tree():
	EditorInterface.get_selection().selection_changed.disconnect(_selection_changed)
	
	for b in [_btn, _btn_new, _btn_remove]:
		if b:
			remove_control_from_container(CONTAINER_SPATIAL_EDITOR_MENU, b)
			_btn.queue_free()
			b = null

func _update_gizmo_neighbors(selected_nodes : Array[Node], i_on_j_action: Callable, action_name: String, do_action_once = null, undo_action_once = null):
	
	var location_nodes : Array[Location] = []
	location_nodes.assign(selected_nodes.filter(func (x): return x is Location))


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
	
	if do_action_once:
		do_action_once.call()
	
	for i in range(location_nodes.size()):
		ur.add_do_property(location_nodes[i], "neighbors", after[i].duplicate(true))
		ur.add_undo_property(location_nodes[i], "neighbors", before[i].duplicate(true))

		ur.add_do_method(location_nodes[i], "update_gizmos")
		ur.add_undo_method(location_nodes[i], "update_gizmos")

	if undo_action_once:
		undo_action_once.call()
	ur.commit_action()


func _on_pressed():
	var action := func(output_array: Array[Array], location_nodes: Array[Location], i: int, j: int):
		var node_i: Location = location_nodes[i]
		var node_j: Location = location_nodes[j]
		if node_i == node_j:
			return
		if output_array[j].find(node_i) == -1:
			output_array[j].append(node_i)

	_update_gizmo_neighbors(EditorInterface.get_selection().get_selected_nodes(), action, "Connect Neighbors")


func _on_pressed_disconnect():
	var action := func(output_array: Array[Array], location_nodes: Array[Location], i: int, j: int):
		var node_i: Location = location_nodes[i]
		var node_j: Location = location_nodes[j]
		if node_i == node_j:
			return
		var idx := output_array[i].find(node_j)
		if idx != -1:
			output_array[i].remove_at(idx)
	
	var selected_nodes = EditorInterface.get_selection().get_selected_nodes()
	if selected_nodes.filter(func (x): return x is Location).size() != 1:
		#default behavior, disconnect all neighbors in selection
		_update_gizmo_neighbors(selected_nodes, action, "Disconnect Neighbors")
		return
	
	# Remove all neighbors of the only selection.
	var neighbor_group : Array[Node] = selected_nodes.filter(func (x): return x is Location)
	var only_node : Location = neighbor_group[0] as Location
	for loc in only_node.neighbors:
		neighbor_group.append(loc)
	
	var action_singular := func(output_array: Array[Array], location_nodes: Array[Location], i: int, j: int):
		if location_nodes[i] != only_node and location_nodes[j] != only_node: 
			return
		action.call(output_array, location_nodes, i, j)
	_update_gizmo_neighbors(neighbor_group, action_singular, "Disconnect Neighbors (Singular)")
	

func _on_pressed_new():
	var selected_nodes = EditorInterface.get_selection().get_selected_nodes()
	
	# Create new location
	var new_location = Location.new()
	get_editor_interface().get_edited_scene_root().add_child(new_location)
	
	new_location.owner = get_editor_interface().get_edited_scene_root()
	var _add_node_ur := func ():
		get_undo_redo().add_do_method(get_editor_interface().get_edited_scene_root(), "add_child", new_location )
		get_undo_redo().add_do_property(new_location, "owner", get_editor_interface().get_edited_scene_root())
	var _remove_node_ur := func ():
		get_undo_redo().add_undo_method(new_location, "queue_free" )
		get_editor_interface().get_edited_scene_root().remove_child(new_location)
		
	var count : int = 0
	for node in selected_nodes:
		if node is Node3D:
			new_location.global_position += node.global_position
			count += 1
	
	if count != 0:
		new_location.global_position /= count
	
	# Essentially i assume every pair in the selection is called on this, but i only do the adding if its for the new node.
	var action := func(output_array: Array[Array], location_nodes: Array[Location], i: int, j: int):
		var node_i: Location = location_nodes[i]
		if node_i != new_location and location_nodes[j] != new_location:
			return
		output_array[j].append(node_i)
		
	selected_nodes.append(new_location)
	_update_gizmo_neighbors(selected_nodes, action, "New Location", _add_node_ur, _remove_node_ur)
	
	# Make newly created node the selection
	EditorInterface.get_selection().clear()
	EditorInterface.get_selection().add_node(new_location)
	

func _selection_changed():
	var nodes: Array = EditorInterface.get_selection().get_selected_nodes()
	for node in nodes:
		if node is Location:
			# if one found
			for b in _buttons:
				b.visible = true
			return
	
	# if no location found
	for b in _buttons:
		b.visible = false
	
