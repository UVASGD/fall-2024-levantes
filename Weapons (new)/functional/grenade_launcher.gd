class_name Grenade_Launcher extends "res://Weapons (new)/functional/gun.gd"


# Called when the node enters the scene tree for the first time.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func shoot():
	await play_fire()
	Curr_Mag_Ammo -= 1
	SignalBus.emit_signal("update_ammo", Curr_Mag_Ammo)
	#hud.update_ammo(Curr_Mag_Ammo, Reserve_Ammo, Weapon_Indicator)
	if Curr_Mag_Ammo == 0:
		if Reserve_Ammo > 0:
			await reload()
		else:
			can_shoot = false #out of all ammo

func create_projectile():
	var projectile = load("res://projectiles/launch_grenade.tscn").instantiate()
	add_child(projectile)
	projectile.get_child(0).throw()
