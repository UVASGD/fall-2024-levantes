extends Node3D
# Called when the node enters the scene tree for the first time.
func _ready():
	$Area3D.connect("body_entered", _on_body_entered)
	$Area3D.connect("body_exited", _on_body_exited)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_body_entered(body):
	if (body.is_in_group("Player")):
		print("gravity 6")
		PhysicsServer3D.area_set_param(get_viewport().find_world_3d().space, PhysicsServer3D.AREA_PARAM_GRAVITY, 6)
		
func _on_body_exited(body):
	if (body.is_in_group("Player")):
		print("gravity 12")
		PhysicsServer3D.area_set_param(get_viewport().find_world_3d().space, PhysicsServer3D.AREA_PARAM_GRAVITY, 12)
