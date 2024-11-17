extends Node3D

@export var damage: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	print("hi")
	$telegraph_animation.play("attack")
	SignalBus.connect("player_death", die)
	pass # Replace with function body.

func playattack():
	print("bye")
	$attack_animation.play("circle_animation")
	$Area3D/CollisionShape3D.disabled = false
	return

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func die():
	$Area3D/CollisionShape3D.disabled = true
	self.queue_free()

func _on_area_3d_body_entered(body: Node3D) -> void:
	SignalBus.emit_signal("player_hit", damage)
	pass # Replace with function body.
