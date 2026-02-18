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
		var lines = PackedVector3Array()
		
		for neighbor : Location in node3d.neighbors:
			# Gizmo lines are in local space, this accounts for the node3d being rotated and moved (and scaled?)
			var offset :=  node3d.to_local(neighbor.global_position)
			var start := Vector3(0, 0.0, 0)
			lines.push_back(lerp(start,offset,0.2))
			lines.push_back(lerp(start,offset,0.8))
			var s = 0.2
			var count = 5
			var gap_length = 0.02
			var total = 0.2
			var line_length = total / count
			for i in range(0,count):
				lines.push_back(lerp(start,offset,s - gap_length - i * line_length ))
				lines.push_back(lerp(start,offset,s - (i + 1) * line_length ))
				
				
				
		gizmo.add_lines(lines, get_material("lines", gizmo), false)
	else:
		print("HUH")
