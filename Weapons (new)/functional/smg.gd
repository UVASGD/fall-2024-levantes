extends Gun

# Called every frame. 'delta' is the elapsed time since the previous frame.
var projectile = preload("res://projectiles/smg_projectile.tscn")

func melee():
	_raycast(melee_dmg, 1.0, Melee_Range)

var flip:int = 0
func shoot(): #default shoot logic
	while Input.is_action_pressed("Shoot") and can_shoot:
		#await get_tree().create_timer(Shoot_Cooldown_Ms).timeout
		
		await play_fire()
		SignalBus.emit_signal("weapon_fire_recoil", recoil_amount, snap_amount, recoil_speed)
		flip = !flip
		create_projectile(flip)
		_raycast(dmg, headshot_multiplier, Projectile_Range)
		Curr_Mag_Ammo -= 1
		SignalBus.emit_signal("update_ammo", Curr_Mag_Ammo)
	#hud.update_ammo(Curr_Mag_Ammo, Reserve_Ammo, Weapon_Indicator)
		if Curr_Mag_Ammo == 0:
			if Reserve_Ammo > 0:
				await reload()
				SignalBus.emit_signal("call_hud_initialize")
			else:
				can_shoot = false #out of all ammo
	pass

func create_projectile(flip:int):
	if flip == 0:
		var projectile_instance = projectile.instantiate()
		get_parent().add_child(projectile_instance)
		
		projectile_instance.global_transform.origin = %marker.global_transform.origin
		var spawn_pos = %marker.global_transform.origin
		var direction = (%marker.global_transform.basis.z * -1).normalized()  

		#var random_angle = randf_range(-0.5, 0.5) # Random angle in degrees
		#var axis = Vector3.UP # Rotate around the UP axis
		#var rotation_matrix = Basis(axis, deg_to_rad(random_angle))
		#var deviated_direction = rotation_matrix * direction
		
		var speed = 300
		projectile_instance.velocity = direction * speed  

func p_mag_in():
	%mag_in.play()
	
func p_mag_out():
	%mag_out.play()
