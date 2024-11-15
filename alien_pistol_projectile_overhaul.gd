extends "res://throwable.gd"

var explosion = preload("res://projectiles/explosion.tscn")
# Called when the node enters the scene tree for the first time.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_body_entered(body):
	SignalBus.emit_signal("enemy_hit", damage, body)
	self.queue_free()
