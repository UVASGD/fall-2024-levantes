extends Node3D

@onready var player = $CharacterBody3D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _physics_process(delta):
	get_tree().call_group("enemies", "update_target_location", player.global_transform.origin)