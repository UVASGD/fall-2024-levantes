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
		create_projectile()
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

func create_projectile():
	var projectile = load("res://projectiles/alien_lmg_projectile.tscn").instantiate()
	%projectile_spawn.add_child(projectile)
	projectile.change_dmg(dmg)
	projectile.throw()
