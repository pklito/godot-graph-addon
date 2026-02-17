class_name Util

static func headingToNode3D(from : Node3D, to : Node3D) -> float:
	var vector3d : Vector3 = to.global_position - from.global_position
	vector3d.y = 0.0
	return vector3d.angle_to(Vector3(0.0,0.0,1.0))


static func headingDistanceTo(angle_base : float, angle_target : float) -> float:
	var a1 = fposmod(angle_base, TAU) 
	var a2 = fposmod(angle_target, TAU)
	print("%s %s" % [rad_to_deg(a1), rad_to_deg(a2)])
	if abs(a2 - a1)  > PI:
		return TAU-(a1 - a2)
	return a2 - a1
	
