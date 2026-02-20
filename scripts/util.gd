class_name Util

static func headingToNode3D(from : Node3D, to : Node3D) -> float:
	var vector3d : Vector3 = to.global_position - from.global_position
	vector3d.y = 0.0
	return -vector3d.signed_angle_to(Vector3(0.0,0.0,1.0), Vector3(0.0,1.0,0.0))


static func headingDistanceTo(angle_base : float, angle_target : float) -> float:
	return fposmod(angle_target - angle_base + PI, TAU) - PI
	

## returns the key which has the value of the smalles value, based on the given metric
static func minValueInDict(dict : Dictionary, metric : Callable = func(x) : return x) -> Variant:
	var _min_value = 100000000
	var _min_key = null
	for k in dict.keys():
		var k_val =  metric.call(dict[k])
		print("search, %s %s" % [rad_to_deg(k_val), k])
		if k_val < _min_value:
			_min_value = k_val
			_min_key = k
	print("done")
	return _min_key
