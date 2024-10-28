extends Gun



# Called every frame. 'delta' is the elapsed time since the previous frame.

func melee():
	_raycast(melee_dmg, Melee_Range)
	pass
	
func call_melee_animation():
	animation_player.play(Melee_Ani)
