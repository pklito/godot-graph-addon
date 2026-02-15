@tool
extends EditorNode3DGizmoPlugin

func _get_gizmo_name() -> String:
	return "Location Lines"

func _init() -> void:
	
	create_material("lines", Color(0.669, 0.761, 0.984, 1.0))
	
	
	create_material("sphere", Color(0.2, 0.71, 0.984, 1.0))
	


func _has_gizmo(node: Node3D) -> bool:

	return node is Location

func _redraw(gizmo: EditorNode3DGizmo) -> void:
	gizmo.clear()
	
	var node3d := gizmo.get_node_3d()

	
	if node3d is Location:
		for neighbor : Location in node3d.neighbors:
			var lines = PackedVector3Array()
			var offset := neighbor.position - node3d.position
			var start := Vector3(0, 0.0, 0)
			lines.push_back(lerp(start,offset,0.1))
			lines.push_back(lerp(start,offset,0.9))
			
			var sphere := SphereMesh.new()
			sphere.radius = 0.2
			sphere.height = 0.4
			sphere.radial_segments = 12
			sphere.rings = 8
			
			gizmo.add_mesh(sphere, get_material("sphere", gizmo), Transform3D(Basis.IDENTITY, lerp(start,offset,0.1)))
			gizmo.add_lines(lines, get_material("lines", gizmo), false)
	else:
		print("HUH")
