extends Node3D

"""TODO: 
	script music and music changes 
	"""
# Called when the node enters the scene tree for the first time.
func _ready():
	$Timer.connect("timeout", _on_timer_timeout)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_glass_broken():
	$AudioStreamPlayer.stream_paused = true
	$Timer.start()
	

func _on_timer_timeout():
	$AudioStreamPlayer2.playing = true
	for enemy in $Enemies.get_children():
		enemy.can_move = true
