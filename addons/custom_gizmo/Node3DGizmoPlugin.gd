# MyCustomEditorPlugin.gd
@tool
extends EditorPlugin


const MyCustomGizmoPlugin = preload("custom_gizmo.gd")
const MyCustomGizmoPlugin2 = preload("neighbor_lines.gd")


var gizmo_plugin = MyCustomGizmoPlugin.new()
var gizmo_plugin2 = MyCustomGizmoPlugin2.new()



func _enter_tree():
	print("My Gizmo Plugin Loaded")
	add_node_3d_gizmo_plugin(gizmo_plugin)
	add_node_3d_gizmo_plugin(gizmo_plugin2)
	


func _exit_tree():
	remove_node_3d_gizmo_plugin(gizmo_plugin)
	remove_node_3d_gizmo_plugin(gizmo_plugin2)
	
