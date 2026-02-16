extends Node3D

@export var nearestLocation : Location

func _calculateNearestLocation() -> Location:
	var grid = $"../Grid"
	var closest_locations : Array = grid.get_children()
	closest_locations.sort_custom(func(node1, node2) : return node1.global_position.distance_squared_to(global_position) < node2.global_position.distance_squared_to(global_position))
	return closest_locations[0] as Location

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if nearestLocation == null:
		nearestLocation = _calculateNearestLocation()
	global_position = nearestLocation.global_position


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
