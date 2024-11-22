class_name Grenade_Launcher extends "res://Weapons (new)/functional/gun.gd"


# Called when the node enters the scene tree for the first time.

var local_can_shoot = true
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func shoot():
	if local_can_shoot and Curr_Mag_Ammo > 0:
		local_can_shoot = false
		await play_fire()
		Curr_Mag_Ammo -= 1
		SignalBus.emit_signal("update_ammo", Curr_Mag_Ammo)
		#hud.update_ammo(Curr_Mag_Ammo, Reserve_Ammo, Weapon_Indicator)
		if Curr_Mag_Ammo == 0:
			local_can_shoot = false
			if Reserve_Ammo > 0:
				await reload()
				local_can_shoot = true
			else:
				can_shoot = false #out of all ammo
				local_can_shoot = true
		local_can_shoot = true

func create_projectile():
	var projectile = load("res://projectiles/launch_grenade.tscn").instantiate()
	$projectile_spawn_point.add_child(projectile)
	projectile.get_child(0).throw()
