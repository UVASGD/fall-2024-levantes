extends Gun

func shoot():
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

	for i in range(0, refill_amount):
		animation_player.play("shotgun/reload_shells")
		await animation_player.animation_finished
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
