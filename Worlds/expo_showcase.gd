extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	$normalmusic.volume_db = 0
	$combatmusic.volume_db = -80

	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass





func _on_area_3d_body_entered(body):
	if body is Player:
		var temp = $normalmusic.volume_db
		$normalmusic.volume_db = $combatmusic.volume_db
		$combatmusic.volume_db = temp
	pass # Replace with function body.
