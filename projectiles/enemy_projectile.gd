extends Area3D

signal ya_got_hit

var damage_amount = 50
@export var time_to_despawn_in_seconds = 5
@onready var timer = $Timer


var velocity = Vector3.ZERO
# Called when the node enters the scene tree for the first time.
func _ready():
	timer.wait_time = time_to_despawn_in_seconds
	timer.start()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	global_transform.origin  += velocity * delta
	pass



func _on_body_entered(body):
	if body.is_in_group("Player"):
		SignalBus.emit_signal("player_hit", damage_amount)
		#print("you got hit!!!!")
		#print("ya_got_hit")
	elif body is StaticBody3D:
		$".".queue_free()
	pass # Replace with function body.




func _on_timer_timeout():
	$".".queue_free()
	#print("freed!!!!" + str(timer.wait_time))
	pass # Replace with function body.
