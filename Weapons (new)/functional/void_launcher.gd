class_name Void_Launcher extends "res://Weapons (new)/functional/gun.gd"


# Called when the node enters the scene tree for the first time.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

var local_can_shoot = true
func shoot():
	if local_can_shoot and Curr_Mag_Ammo > 0:
		local_can_shoot = false
		await play_fire()
		Curr_Mag_Ammo -= 1
		SignalBus.emit_signal("update_ammo", Curr_Mag_Ammo)
		#hud.update_ammo(Curr_Mag_Ammo, Reserve_Ammo, Weapon_Indicator)
		if Curr_Mag_Ammo == 0:
			if Reserve_Ammo > 0:
				await reload()
				local_can_shoot = true
			else:
				can_shoot = false #out of all ammo
				local_can_shoot = false
		local_can_shoot = true

func create_projectile():
	var projectile = load("res://projectiles/void.tscn").instantiate()
	$MeshInstance3D/projectile_spawn_point.add_child(projectile)
	projectile.throw()
