extends Gun


func shoot(): #default shoot logic
	if can_shoot:
		can_shoot = false
		#await get_tree().create_timer(Shoot_Cooldown_Ms).timeout
		var Curr_Ammo_Loop = Curr_Mag_Ammo #loop safe variable
		_raycast(dmg, headshot_multiplier, Projectile_Range)
		Curr_Mag_Ammo -= 1
		SignalBus.emit_signal("update_ammo", Curr_Mag_Ammo)
		await play_fire()
		
		if Curr_Mag_Ammo == 0:
			if Reserve_Ammo > 0:
				await reload()
			else:
				can_shoot = false
				return
		can_shoot = true

func melee():
	_raycast(melee_dmg, 1.0, Melee_Range)
