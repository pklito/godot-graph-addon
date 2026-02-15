@tool
@icon("res://assets/textures/down_arrow.svg")


extends Node3D
class_name Location

@export var neighbors : Array[Location] = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
