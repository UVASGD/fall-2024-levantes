extends Node3D

var dir
# Called when the node enters the scene tree for the first time.
func _ready():
	dir = Vector3(0,0.01,0)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if randi_range(0,240) == 5:
		dir = -dir
	self.global_position += dir
	pass
