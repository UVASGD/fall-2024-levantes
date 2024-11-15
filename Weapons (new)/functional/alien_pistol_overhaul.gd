#class_name AlienPistol extends "res://Weapons (new)/functional/gun.gd"
extends Gun
var is_charging = false
var charge_time = 0.0
var max_charge_time = 1.0
var crit_time = 0.75
var can_fire = false


func _physics_process(delta: float) -> void:
	if can_fire:
		if Input.is_action_just_pressed("Shoot"):
			start_charging()
		elif Input.is_action_just_released("Shoot"):
			release_shot()
		if is_charging:
			charge_time += delta
			charge_time = min(charge_time, max_charge_time)
		pass

func start_charging():
	is_charging = true
	animation_player.play("alien_pistol/charge")
	charge_time = 0.0
	print("Charging started")


func release_shot():
	print("charge released")
	print(charge_time)
	animation_player.stop()
	is_charging = false
	if charge_time >= crit_time and charge_time < 1.0:
		crit_shot()
	else:
		shoot()
	charge_time = 0.0

func shoot():
	#if Input.is_action_just_pressed("Shoot"):
		#start_charging()
	#elif Input.is_action_just_released("Shoot"):
		#release_shot()
	for i in range(0,2):
		
		await play_fire()
		Curr_Mag_Ammo -= 1
		SignalBus.emit_signal("update_ammo", Curr_Mag_Ammo)
	#hud.update_ammo(Curr_Mag_Ammo, Reserve_Ammo, Weapon_Indicator)
		if Curr_Mag_Ammo == 0:
			if Reserve_Ammo > 0:
				await reload()
			else:
				can_shoot = false #out of all ammo
	
		
	return
	#if can_shoot:
		#can_shoot = false
		##await get_tree().create_timer(Shoot_Cooldown_Ms).timeout
		#var Curr_Ammo_Loop = Curr_Mag_Ammo #loop safe variable
		#for i in min(Burst_Count, Curr_Ammo_Loop):
			#_raycast(dmg, headshot_multiplier, Projectile_Range)
			#await play_fire()
			#Curr_Mag_Ammo -= 1
			#SignalBus.emit_signal("update_ammo", Curr_Mag_Ammo)
		#if Curr_Mag_Ammo == 0:
			#if Reserve_Ammo > 0:
				#await reload()
			#else:
				#can_shoot = false
				#return
		##Is_Waiting = true
		##animation_player.play(Wait_Ani)
		##await Animation_Player.animation_finished
		#await get_tree().create_timer(Wait_Interval).timeout
		##Is_Waiting = false
		#can_shoot = true
		#
func crit_shot():
	print("crit")
	await shoot()
	animation_player.play("alien_pistol/overheat")
	return

func create_projectile():
	var projectile = load("res://projectiles/alien_pistol_projectile_overhaul.tscn").instantiate()
	%projectile_spawn.add_child(projectile)
	projectile.throw()

func create_shockwave():
	print("make shock")
	var shock = load("res://projectiles/nice_shockwave.tscn").instantiate()
	get_node("../../../../").add_child(shock)
	return
	
func equip():
	can_fire = true
	if !can_equip:
		return
	can_shoot = false
	can_reload = false
	can_dequip = false
	can_equip = false
	
	show()
	print("playing $Name equip")
	animation_player.play(Equip_Ani)
	await animation_player.animation_finished
	print("finished $Name equip")
	if(Curr_Mag_Ammo > 0):
		can_shoot = true
	can_reload = true
	can_dequip = true

func dequip():
	can_fire = false
	if !can_dequip:
		return
	can_equip = false
	can_shoot = false
	can_reload = false
	can_dequip = false
	print("playing $Name dequip")
	animation_player.play(Dequip_Ani)
	await animation_player.animation_finished
	print("finished $Name dequip")
	hide()
	
	can_equip = true
	return
	
