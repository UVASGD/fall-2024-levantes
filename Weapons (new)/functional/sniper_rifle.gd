extends Gun


func shoot(): #default shoot logic
	if can_shoot:
		can_shoot = false
		#await get_tree().create_timer(Shoot_Cooldown_Ms).timeout
		var Curr_Ammo_Loop = Curr_Mag_Ammo #loop safe variable
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
		can_shoot = true

func melee():
	_raycast(melee_dmg, Melee_Range)

func _raycast(dmg, range):
	var camera = get_parent().get_parent()
	var space_state = camera.get_world_3d().direct_space_state
	var screen_center = get_viewport().size / 2
	var origin = camera.project_ray_origin(screen_center)
	var direction = camera.project_ray_normal(screen_center).normalized()
	var remaining_range = range
	var max_hits = 10

	for i in range(max_hits):
		if remaining_range <= 0:
			break 

		var endpoint = origin + direction * remaining_range
		var query = PhysicsRayQueryParameters3D.create(origin, endpoint)
		query.collide_with_bodies = true
		query.collide_with_areas = false

		var intersection = space_state.intersect_ray(query)
		if intersection.is_empty() or not intersection.get("collider").is_in_group("enemies"):
			break  

		SignalBus.emit_signal("enemy_hit", dmg, intersection.get("collider"))

		# Update remaining range and start the next segment from the intersection point
		var hit_position = intersection.get("position")
		var distance_to_hit = origin.distance_to(hit_position)
		remaining_range -= distance_to_hit
		origin = hit_position + direction * 0.1  # Small offset to prevent hitting the same collider again

		# Optional: Reduce damage for each successive hit
		# dmg *= 0.9  # Reduce damage to 90% per hit (optional)
