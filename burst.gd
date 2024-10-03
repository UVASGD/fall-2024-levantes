extends Gun



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#print(hidden)
	pass

func shoot():
	var is_wait = Is_Waiting
	var is_rel = Is_Reloading
	var cur_mag_ammo = Curr_Mag_Ammo
	var burst_amount = Burst_Count
	
	var cur_anim = animation_player.get_current_animation()
	var ammo_checks = cur_mag_ammo != 0 and cur_mag_ammo >= burst_amount
	
	if ammo_checks:
		var checks = (cur_anim != Dequip_Ani and cur_anim != Equip_Ani and cur_anim != Reload_Ani and !is_wait and !is_rel)
		if !checks:
			pass
		elif checks:
			for i in range(burst_amount):
				if Is_Reloading:
					Is_Reloading = false
				#elif i == 2:
					#await Animation_Player.animation_finished
				animation_player.play(Fire_Ani)
				audio_player.play()
				_raycast()
				#print(str(Current_Weapon.Curr_Mag_Ammo) + "\n")
				Curr_Mag_Ammo -= 1
				await animation_player.animation_finished
				#hud.update_ammo(Curr_Mag_Ammo, Reserve_Ammo, Weapon_Indicator)
				#if i == burst_amount-1:
					#await Animation_Player.animation_finished
			Is_Waiting = true
			animation_player.play(Wait_Ani)
			#await Animation_Player.animation_finished
			await get_tree().create_timer(Wait_Interval).timeout
			Is_Waiting = false
	pass
