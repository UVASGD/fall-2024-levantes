extends husk_weapon


# Called when the node enters the scene tree for the first time.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_weapon():
	var new_gun = load(real_weapon_path)
	var new_gun_scene = new_gun.instantiate()
	return new_gun_scene
