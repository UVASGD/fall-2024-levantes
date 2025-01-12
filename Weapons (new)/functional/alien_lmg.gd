extends Gun

var player: CharacterBody3D
@export var knockback_force: float = 1.0
func _ready():
	var model = get_child(0)
	animation_player = get_node(animation_player_treepath)
	#print(animation_player)
	audio_player = AudioStreamPlayer.new()
	audio_player.max_polyphony = max_pol
	audio_player.pitch_scale = change_pitch_mult
	audio_player.volume_db = volume_db_increase
	audio_player.stream = load(Fire_Sound)
	add_child(audio_player)
	var root = get_tree().root
	can_equip = true
	
	player = get_tree().get_nodes_in_group("Player")[0]
	
	
func shoot(): #default shoot logic
	while Input.is_action_pressed("Shoot") and can_shoot:
		#await get_tree().create_timer(Shoot_Cooldown_Ms).timeout
		
		SignalBus.emit_signal("weapon_fire_recoil", recoil_amount, snap_amount, recoil_speed)
		var dir = _proj_raycast_check(Projectile_Range)[0]
		var endpoint = _proj_raycast_check(Projectile_Range)[1]
		print("Direction vector: ", dir)
		create_projectile(dir)
		
		#create_projectile()
		
		if player and not player.is_on_floor():
		# Calculate knockback direction (opposite to the gun's forward direction)
			var knockback_direction = global_transform.basis.z.normalized()
				
			# Apply force to the player
			player.velocity += knockback_direction * knockback_force
		await play_fire()
		
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

#func create_projectile(direction: Vector3):
	#var projectile = load("res://projectiles/alien_lmg_projectile.tscn").instantiate()
	#projectile.damage = dmg
	#projectile.global_transform.origin = %projectile_spawn.global_transform.origin
	#projectile.new_throw(direction)
	#get_parent().add_child(projectile)
	#
	
func create_projectile(dir):
	var projectile = load("res://projectiles/alien_lmg_projectile.tscn").instantiate()
	%projectile_spawn.add_child(projectile)
	projectile.look_at(dir, Vector3.UP)
	projectile.throw()

func _proj_raycast_check(range):
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
		var collision_point = intersection.get("position")
		var direction = (collision_point - origin).normalized()
		return [direction, collision_point]
	else:
		# Default forward direction if no collision
		return [camera.project_ray_normal(screen_center).normalized(), endpoint]
