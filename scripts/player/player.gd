extends Node3D
class_name Player

@export var nearestLocation : Location

@export var MOVE_SPEED : float = 1.8
@export var MAX_SNAP_ANGLE : float = 40
@export var MAX_TURN_ANGLE : float = 110



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
		
	var _dict : Dictionary[Location,float] = _currentLocation.getNeighborsMap()
	
	
	if Input.is_action_just_pressed("forward"):
		var _min_angle := TAU
		var _min_loc : Location = null
		for n in _dict.keys():
			if abs(Util.headingDistanceTo(_yaw, _dict[n])) < _min_angle:
				_min_angle = abs(Util.headingDistanceTo(_yaw, _dict[n]))
				_min_loc = n
		
		if _min_loc == null:
			printerr("No neighbors when pressing forward")
			return
			
		if _min_angle > deg_to_rad(MAX_SNAP_ANGLE):
			push_warning("No neighbors facing this direction!")
			return
			
		
		_nextLocation = _min_loc
		_yaw = _dict[_min_loc]
		global_rotation.y = _yaw
		print(_dict.keys() + _dict.values())
		
		
	if Input.is_action_pressed("left"):
		_yaw += 3 * delta
		global_rotation.y = _yaw
		
	if Input.is_action_pressed("right"):
		_yaw -= 3 * delta
		global_rotation.y = _yaw
		

func _physics_process(delta: float) -> void:
	if isMoving():
		var _move_vector :Vector3 = (_nextLocation.global_position - global_position)
		if _move_vector.length_squared() <= pow(1 * delta * MOVE_SPEED, 2):
			global_position = _nextLocation.global_position
			_currentLocation = _nextLocation
			return
		
		global_position += _move_vector.normalized() * delta * MOVE_SPEED

func _calculateNearestLocation() -> Location:
	var grid = $"../Grid"
	var closest_locations : Array = grid.get_children()
	closest_locations.sort_custom(func(node1, node2) : return node1.global_position.distance_squared_to(global_position) < node2.global_position.distance_squared_to(global_position))
	return closest_locations[0] as Location

# Called when the node enters the scene tree for the first time.
