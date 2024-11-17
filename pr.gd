extends MeshInstance3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	play_animation()
	pass # Replace with function body.


## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#self.rotation_degrees = self.rotation_degrees + Vector3(0,1,0)
	#pass

func play_animation():
	$AnimationPlayer.play("idle")
