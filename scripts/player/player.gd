extends Node3D
class_name Player

@export var nearestLocation : Location

@export_category("Move")
@export var MOVE_SPEED : float = 1.8
@export var MAX_SNAP_ANGLE_WALK : float = 40

@export_category("Turn")
@export var TURN_SPEED := 3
@export var TURN_ANGLE_EXTRA : float = 30
@export var TURN_ANGLE : float = 90




var _currentLocation : Location = null
var _nextLocation : Location = null
var _yaw : float = 0.0
var _targetYaw : float = 0.0
func _ready() -> void:
	
	if nearestLocation == null:
		nearestLocation = _calculateNearestLocation()
	
	snapTo(nearestLocation)
	
	_yaw = global_rotation.y


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	_handle_inputs(delta)
	

func isMoving() -> bool:
	return _currentLocation != _nextLocation

func isSpinning() -> bool:
	return abs(_yaw - _targetYaw ) > 0.01

func snapTo(location : Location):
	_currentLocation = location
	_nextLocation = location
	
	global_position = _currentLocation.global_position

func _turn_min(dict : Dictionary, clockwise : bool) -> float:
	var angle_right := func (f) : 
		var offset := Util.headingDistanceTo(_yaw, f)
		offset = -offset if clockwise else offset
		if offset < deg_to_rad(3):
			return offset + TAU
		return offset
	var _min_loc : Location = Util.minValueInDict(dict, angle_right)
	
	var turn_angle = deg_to_rad(TURN_ANGLE)
	var _min_angle = angle_right.call(dict[_min_loc])
	_min_angle = -_min_angle if clockwise else _min_angle
	turn_angle = -turn_angle if clockwise else turn_angle
	
	if _min_loc and abs(_min_angle) < deg_to_rad(TURN_ANGLE + TURN_ANGLE_EXTRA):
		turn_angle = _min_angle
	return turn_angle


func _handle_inputs(delta : float):
	if isMoving():
		return
		
	var _dict : Dictionary[Location,float] = _currentLocation.getNeighborsMap()
	
	if Input.is_action_just_pressed("forward"):
		var angle_dist := func (f) : return abs(Util.headingDistanceTo(_yaw, f))
		var _min_loc : Location = Util.minValueInDict(_dict, angle_dist)
		if _min_loc == null:
			printerr("No neighbors when pressing forward")
			return
			
		var _min_angle = angle_dist.call(_dict[_min_loc])
		if _min_angle > deg_to_rad(MAX_SNAP_ANGLE_WALK):
			push_warning("No neighbors facing this direction!")
			return
			
		
		_nextLocation = _min_loc
		_targetYaw = _dict[_min_loc]
		
		
	if Input.is_action_just_pressed("left"):
		if isSpinning():
			return
		_targetYaw = _yaw + _turn_min(_dict, false)
		
	if Input.is_action_just_pressed("right"):
		if isSpinning():
			return
		_targetYaw = _yaw + _turn_min(_dict, true)
		

func _physics_process(delta: float) -> void:
	if isSpinning():
		var speed := TURN_SPEED
		if(abs(Util.headingDistanceTo(_yaw, _targetYaw)) < 2 * delta * speed):
			_yaw = _targetYaw
		_yaw += delta * speed * sign(Util.headingDistanceTo(_yaw, _targetYaw))
		global_rotation.y = _yaw

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
