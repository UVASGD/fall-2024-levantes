extends Area3D

@export var manager_: Node
var entities_overlapping
var player_overlapping: bool = false

func _on_body_entered(body):
	if body.is_in_group("Player"):
		manager_.entity_state = manager_.ENTITY_STATE.ATTACK
		player_overlapping = true
		
func _on_body_exited(body):
	if body.is_in_group("Player"):
		manager_.entity_state = manager_.ENTITY_STATE.CHASE
