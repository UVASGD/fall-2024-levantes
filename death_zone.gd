extends Node3D
# Called when the node enters the scene tree for the first time.
func _ready():
	$Area3D.connect("body_entered", _on_body_entered)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_body_entered(body):
	if(body.is_in_group("enemies")):
		print("enemy fell")
		SignalBus.emit_signal("enemy_hit", 1000, 2, body, 1)
	elif (body.is_in_group("Player")):
		SignalBus.emit_signal("player_hit", 1000)
		SignalBus.emit_signal("player_hit", 1000) #second time because of max damage constraint
