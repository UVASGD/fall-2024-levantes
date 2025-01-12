extends "res://throwable.gd"
@export var sound: AudioStream
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
	var audio_player = AudioStreamPlayer3D.new()
	audio_player.stream = sound
	audio_player.volume_db = 10
	audio_player.global_transform = self.global_transform
	get_parent().add_child(audio_player)
	audio_player.play()
	audio_player.connect("finished", queue_free)
	$".".queue_free()
	await explosion_instance.animation_player.animation_finished
	
	
