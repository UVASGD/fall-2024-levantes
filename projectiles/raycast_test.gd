class_name Raycast_test extends Node3D

const Sparks = preload("res://projectiles/spark.gd")
var impactpoint
var directionval
# Called when the node enters the scene tree for the first time.
func _ready():
	var sparks = Sparks.new()
	sparks.direction = directionval
	sparks.impactpoint = impactpoint
	self.add_child(sparks)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

