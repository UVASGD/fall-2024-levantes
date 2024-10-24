extends "res://throwable.gd"

var explosion = preload("res://projectiles/explosion.tscn")
# Called when the node enters the scene tree for the first time.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func action():
	var explosion_instance = explosion.instantiate()

	explosion_instance.damage_amount = damage

	explosion_instance.global_transform.origin = global_transform.origin
	var spawn_pos = global_transform.origin
	spawn_pos.y += -1

	get_tree().root.add_child(explosion_instance)
	explosion_instance.play_explode_animation()
	hide()
	
	$".".queue_free()
	await explosion_instance.animation_player.animation_finished
	
	

