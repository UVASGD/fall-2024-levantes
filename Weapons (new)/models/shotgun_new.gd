extends Gun

@export var spread_angle_degs:int = 15
var local_is_reloading:bool = true

func _raycast(dmg, hs_mult, range):
	var camera = get_parent().get_parent()
	var space_state = camera.get_world_3d().direct_space_state
	var screen_center = get_viewport().size / 2
	var origin = camera.project_ray_origin(screen_center)
	var pellets_hit = []
	
	for x in range(-1,2):
		for y in range(-1,2):
			var offset = Vector2i(x,y) * spread_angle_degs
			var direction = camera.project_ray_normal(screen_center + offset).normalized()
			var endpoint = origin + direction * Projectile_Range
			
			var query = PhysicsRayQueryParameters3D.create(origin, endpoint)
			query.collide_with_bodies = true
			query.collide_with_areas = false
			var intersection = space_state.intersect_ray(query)
			
			if not intersection.is_empty():
				var collider = intersection.get("collider")
				if collider is CharacterBody3D and collider.is_in_group("enemies"):
					SignalBus.emit_signal("enemy_hit", dmg, hs_mult, collider, intersection.get("shape"))
					pellets_hit.append(collider)
	
	print("Pellets hit: ", pellets_hit)
		#print("nothing")
		

func shoot():
	if can_shoot and Curr_Mag_Ammo > 0:
		can_shoot = false
		
		#await get_tree().create_timer(Shoot_Cooldown_Ms).timeout
		var Curr_Ammo_Loop = Curr_Mag_Ammo #loop safe variable
		local_is_reloading = false
		_raycast(dmg, headshot_multiplier, Projectile_Range)
		Curr_Mag_Ammo -= 1
		SignalBus.emit_signal("update_ammo", Curr_Mag_Ammo)
		await play_fire()
		local_is_reloading = true
		if Curr_Mag_Ammo == 0:
			if Reserve_Ammo > 0:
				await reload()
			else:
				can_shoot = false
				return
		can_shoot = true

func reload():
	if Curr_Mag_Ammo == Max_Mag_Capacity || !can_reload:
		return
	can_dequip = false
	#can_shoot = false
	can_reload = false	
		
	var refill_amount = Max_Mag_Capacity - Curr_Mag_Ammo	
	if Reserve_Ammo <= refill_amount:
		refill_amount = Reserve_Ammo
		Reserve_Ammo = 0
	else:
		Reserve_Ammo -= refill_amount	
	animation_player.play("shotgun/reload")	
	await animation_player.animation_finished
	local_is_reloading = true
	for i in range(0, refill_amount):
		if !local_is_reloading:
			return
		can_shoot = false
		animation_player.play("shotgun/reload_shells")
		await animation_player.animation_finished
		can_shoot = true
		Curr_Mag_Ammo += 1
		SignalBus.emit_signal("call_hud_initialize")
	animation_player.play("shotgun/reload_pump")
	await animation_player.animation_finished
		

		
	#animation_player.play(Reload_Ani)
	#Curr_Mag_Ammo += refill_amount
	#await animation_player.animation_finished
	#SignalBus.emit_signal("call_hud_initialize")
	#hud.update_ammo(Curr_Mag_Ammo, Reserve_Ammo, Weapon_Indicator)
	can_reload = true
	can_shoot = true
	can_dequip = true
	
	pass
	
func play_pump_back_audio():
	%shotgun_pump_back.play()
	
func play_pump_forward_audio():
	%shotgun_pump_forward.play()

func play_shell_load_audio():
	%shotgun_shell_load.play()
