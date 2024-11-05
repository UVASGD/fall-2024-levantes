extends Node3D

@export var damage_amount: int = 50
var is_attacking: bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_hitbox_body_entered(body):
	if is_attacking and body.is_in_group("Player"):
		SignalBus.emit_signal("player_hit", damage_amount)
		is_attacking = false

func attack():
	is_attacking = true
