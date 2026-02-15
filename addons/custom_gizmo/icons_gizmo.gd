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
