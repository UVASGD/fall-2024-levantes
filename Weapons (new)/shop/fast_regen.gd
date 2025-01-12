class_name FastRegen extends "res://powerup.gd"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$model.rotation_degrees = $model.rotation_degrees + Vector3(0,1,0)
	$StaticBody3D.rotation_degrees = $StaticBody3D.rotation_degrees + Vector3(0,1,0)
	pass

func apply():
	PlayerManager.player.shield_regen_timer.wait_time = 3.0
	PlayerManager.player.health_regen_timer.wait_time = 6.0
	self.queue_free()
