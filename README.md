Built for Godot 4.8
This is a godot extension that visualizes nodes and allows you to easily make connected non-directed graphs.

I'm using this repository as a blog-like reference to return to if i return to working with godot, as I am currently working with unity and unreal.
<img width="1300" height="709" alt="output2" src="https://github.com/user-attachments/assets/085f9b46-4bd0-4348-b15a-5b62fea47905" />
This project shown above in this repository has a simple character controller that moves on the predefined graph.
The extension is fully undo/redo compatible.

## Usage
Create a Location node from the regular 'add child node' menu.
Selecting a Location node will show three buttons to the spacial editor menu (the bar on top of the edit screen):  
1. **Connect**: Selecting 2 or more Locations each of them to eachother (fully connected graph).
2. **Disconnect**: Selecting a single node disconnects all of it's neighbors from it. Selecting multiple nodes only disconnects them from eachother.
3. **New**: Create a point that is connected to all of the current selection as is initialized at the COM of the selected nodes.

Each Location maintains an attribute `Neighbors`, which points to all the connected locations. These connections are bi-directional.
## How I coded an addon
Addons are pretty convenient to work with in godot, especially in comparison with other apps, from my experience, besides getting it to do with undos.
[This guide is a good starting point](https://docs.godotengine.org/en/stable/tutorials/plugins/editor/making_plugins.html)  
The three components to this plugin are **The button UI**, **The Connectivity logic**, and **The GUI Gizmos**
### GUI Gizmos
```gdscript
@tool
extends EditorNode3DGizmoPlugin

const ICON := preload("res://assets/textures/down_arrow.svg")

func _get_gizmo_name() -> String:
	return "Location Icons"

func _init() -> void:
	# Key must match what you later pass to get_material()
	create_icon_material("my_icon", ICON)

func _has_gizmo(node: Node3D) -> bool:

	return node is Location

func _redraw(gizmo: EditorNode3DGizmo) -> void:
	gizmo.clear()
	
	# Fetch the icon material you created in _init()
	var mat := get_material("my_icon", gizmo)
	if mat == null:
		return

	# Always-visible “node icon” in the 3D viewport
	gizmo.add_unscaled_billboard(mat, 0.05)
```
This is all it takes to visualize an icon on a node, [and to add this script to the engines gizmos](https://docs.godotengine.org/en/stable/tutorials/plugins/editor/3d_gizmos.html#the-editornode3dgizmoplugin).
The neighborhood line gizmo is pretty much the same, seen [here](addons/custom_gizmo/neighbor_lines_gizmo.gd).
```gdscript
func _notification(what: int) -> void:
	match what:
		NOTIFICATION_TRANSFORM_CHANGED:
			update_gizmos()
			for loc in neighbors:
				loc.update_gizmos()
```
It's important to update the gizmos when one of the locations moves, because they do not recompute every frame.
### Connectivity actions:
This portion is a lot more complicated, the full code can be seen [here](addons/custom_gizmo/group_buttons.gd). The core concept is to run:
```gdscript
var _add_node_ur := func ():
		get_undo_redo().add_do_method(get_editor_interface().get_edited_scene_root(), "add_child", new_location )
		get_undo_redo().add_do_property(new_location, "owner", get_editor_interface().get_edited_scene_root())
//...
		get_undo_redo().add_undo_method(new_location, "queue_free" )
		get_editor_interface().get_edited_scene_root().remove_child(new_location)
```
The resources i used were these: 
- [youtube video](https://www.youtube.com/watch?v=OVf8mtv6444)
- [Documentation page](https://docs.godotengine.org/en/stable/classes/class_undoredo.html#description)

<img width="1335" height="796" alt="image" src="https://github.com/user-attachments/assets/f0e31e58-557f-4c14-b808-5af69a14bcfe" />
