class_name AlienPistol extends "res://Weapons (new)/functional/gun.gd"
var is_charging = false
var charge_time = 0.0
var max_charge_time = 1.0
var crit_time = 0.75



func _process(delta: float) -> void:
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
		regular_shot()
	charge_time = 0.0

func regular_shot():
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
	
func crit_shot():
	print("crit")
	await regular_shot()
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
	
func shoot(): 
	print("wrong shoot")
	pass
