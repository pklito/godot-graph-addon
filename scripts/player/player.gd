extends Node3D
class_name Player

@export var nearestLocation : Location

var _currentLocation : Location = null
var _nextLocation : Location = null
var _yaw : float = 0.0
func _ready() -> void:
	
	if nearestLocation == null:
		nearestLocation = _calculateNearestLocation()
	
	snapTo(nearestLocation)
	
	_yaw = global_rotation.y
	

	print(_yaw)
	print(_currentLocation.getNeighborsMap())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_handle_inputs(delta)
	

func isMoving() -> bool:
	return _currentLocation != _nextLocation

func snapTo(location : Location):
	_currentLocation = location
	_nextLocation = location
	
	global_position = _currentLocation.global_position

func _handle_inputs(delta : float):
	if isMoving():
		return
	if Input.is_action_just_pressed("forward"):
		print(_currentLocation.getNeighborsMap().values().map(func ( x) : return rad_to_deg(Util.headingDistanceTo(_yaw, x))))
		
	if Input.is_action_pressed("left"):
		_yaw += 3 * delta
		global_rotation.y = _yaw
		
	if Input.is_action_pressed("right"):
		_yaw -= 3 * delta
		global_rotation.y = _yaw
		

func _calculateNearestLocation() -> Location:
	var grid = $"../Grid"
	var closest_locations : Array = grid.get_children()
	closest_locations.sort_custom(func(node1, node2) : return node1.global_position.distance_squared_to(global_position) < node2.global_position.distance_squared_to(global_position))
	return closest_locations[0] as Location

# Called when the node enters the scene tree for the first time.
