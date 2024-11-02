extends Gun



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	##print(hidden)
	#pass
@onready var marker = $burstModel/marker
func shoot():
	if can_shoot:
		can_shoot = false
		#await get_tree().create_timer(Shoot_Cooldown_Ms).timeout
		var Curr_Ammo_Loop = Curr_Mag_Ammo #loop safe variable
		for i in min(Burst_Count, Curr_Ammo_Loop):
			_raycast(dmg, Projectile_Range)
			await play_fire()
			Curr_Mag_Ammo -= 1
			SignalBus.emit_signal("update_ammo", Curr_Mag_Ammo)
		if Curr_Mag_Ammo == 0:
			if Reserve_Ammo > 0:
				await reload()
			else:
				can_shoot = false
				return
		#Is_Waiting = true
		#animation_player.play(Wait_Ani)
		#await Animation_Player.animation_finished
		await get_tree().create_timer(Wait_Interval).timeout
		#Is_Waiting = false
		can_shoot = true
	pass

func _raycast(dmg, range):
	var camera = get_parent().get_parent()
	var space_state = camera.get_world_3d().direct_space_state
	var screen_center = get_viewport().size / 2
	var origin = camera.project_ray_origin(screen_center)
	var endpoint = origin + camera.project_ray_normal(screen_center) * range
	var query = PhysicsRayQueryParameters3D.create(origin, endpoint)
	var intersection = get_world_3d().direct_space_state.intersect_ray(query)
	query.collide_with_bodies = true
	query.collide_with_areas = false
	if not intersection.is_empty():
		#make_bullet_trail(intersection.get("position"))
		SignalBus.emit_signal("enemy_hit", dmg, intersection.get("collider"))
		print(intersection.get("collider"))
		
	else:
		print("nothing")
func melee():
	_raycast(melee_dmg, Melee_Range)

func make_bullet_trail(target_pos: Vector3):
	var bullet_dir = (target_pos - marker.global_position).normalized()
	var start_pos = marker.global_position + bullet_dir * 0.25
	if (target_pos - start_pos).length() > 3.0:
		var tracer = preload("res://particles/bullet_tracer.tscn").instantiate()
		add_child(tracer)
		tracer.global_position = start_pos
		tracer.look_at(target_pos + Vector3(0,1,0))
		
		
	
