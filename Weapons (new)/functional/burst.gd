extends Gun



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	##print(hidden)
	#pass
@onready var marker = $burstModel/marker

var projectile = preload("res://projectiles/hitscan_projectile.tscn")
func shoot():
	if can_shoot:
		can_shoot = false
		#await get_tree().create_timer(Shoot_Cooldown_Ms).timeout
		var Curr_Ammo_Loop = Curr_Mag_Ammo #loop safe variable
		for i in min(Burst_Count, Curr_Ammo_Loop):
			_raycast(dmg, headshot_multiplier, Projectile_Range)
			create_projectile()
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

func melee():
	_raycast(melee_dmg, 1.0, Melee_Range)

func make_bullet_trail(target_pos: Vector3):
	var bullet_dir = (target_pos - marker.global_position).normalized()
	var start_pos = marker.global_position + bullet_dir * 0.25
	if (target_pos - start_pos).length() > 3.0:
		var tracer = preload("res://particles/bullet_tracer.tscn").instantiate()
		add_child(tracer)
		tracer.global_position = start_pos
		tracer.look_at(target_pos + Vector3(0,1,0))
		
func create_projectile():
	var projectile_instance = projectile.instantiate()
	get_parent().add_child(projectile_instance)
	
	projectile_instance.global_transform.origin = %marker.global_transform.origin
	var spawn_pos = %marker.global_transform.origin
	var direction = (%marker.global_transform.basis.z * -1).normalized()  

	var speed = 400
	projectile_instance.velocity = direction * speed  

	
