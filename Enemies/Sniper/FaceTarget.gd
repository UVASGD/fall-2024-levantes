extends Node3D


@export var turn_speed = 100.0

func face_point(point: Vector3, delta: float):
	var local_point = to_local(point)
	local_point.y = 0.0
	# turn_dir is neg or positive depending on if its left or right
	var turn_dir = sign(local_point.x)
	var turn_amount = deg_to_rad(turn_speed * delta)
	var angle = Vector3.FORWARD.angle_to(local_point)
	
	if angle < turn_amount:
		turn_amount = angle
	rotate_object_local(Vector3.UP, -turn_amount * turn_dir)

func is_facing_target(target_point: Vector3):
	var local_target_pos = to_local(target_point)
	return local_target_pos.z < 0 and abs(local_target_pos.x) < 1.0
