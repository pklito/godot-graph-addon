@tool
@icon("res://assets/textures/down_arrow.svg")


extends Node3D
class_name Location

@export var neighbors : Array[Location] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	set_notify_transform(true)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_TRANSFORM_CHANGED:
			update_gizmos()
			for loc in neighbors:
				loc.update_gizmos()

var _angleToNeighbors : Dictionary[Location, float] = {}

func getNeighborsMap() -> Dictionary[Location, float]:
	if _angleToNeighbors.is_empty():
		for neighbor in neighbors:
			_angleToNeighbors[neighbor] = Util.headingToNode3D(self, neighbor)
	return _angleToNeighbors
