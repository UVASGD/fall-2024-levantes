extends Node3D


@export var current_turn_speed = 60
@export var normal_turn_speed = 60
@export var retreat_turn_speed = 40
@export var x_axis_angle_threshold = 30.0


func face_point(x_or_y:String, point: Vector3, delta: float):
	match x_or_y:
		"x":
			var local_point = to_local(point)
			local_point.y = 0.0
			# turn_dir is neg or positive depending on if its left or right
			var turn_dir = sign(local_point.x)
			var turn_amount = deg_to_rad(current_turn_speed * delta)
			var angle = Vector3.FORWARD.angle_to(local_point)
			if angle < turn_amount:
				turn_amount = angle
			rotate_object_local(Vector3.UP, -turn_amount * turn_dir)
		"y":
			var local_point = to_local(point)
			local_point.x = 0.0  # Ignore the x component for y-axis rotation

			# First, check if the x-axis angle is within the threshold
			var angle_x = rad_to_deg(Vector3.FORWARD.angle_to(local_point))
			if abs(angle_x) < x_axis_angle_threshold:
				# If within the threshold, proceed with y-axis rotation
				var turn_dir = sign(local_point.y)
				var turn_amount = deg_to_rad(current_turn_speed * delta)
				var angle_y = Vector3.FORWARD.angle_to(local_point)
				if angle_y < turn_amount:
					turn_amount = angle_y
				rotate_object_local(Vector3.RIGHT, turn_amount * turn_dir)
	
	

func is_facing_target(target_point: Vector3):
	var local_target_pos = to_local(target_point)
	return local_target_pos.z < 0 and abs(local_target_pos.x) < 1.0
