extends Gun



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	##print(hidden)
	#pass

func shoot():
	if can_shoot:
		can_shoot = false
		#await get_tree().create_timer(Shoot_Cooldown_Ms).timeout
		var Curr_Ammo_Loop = Curr_Mag_Ammo #loop safe variable
		for i in min(Burst_Count, Curr_Ammo_Loop):
			await play_fire()
			_raycast()
			Curr_Mag_Ammo -= 1
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

	
	