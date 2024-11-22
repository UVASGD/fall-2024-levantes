extends Area3D

signal ya_got_hit

@export var damage_amount = 35
@onready var timer = $Timer
@onready var animation_player = $explosion_animation_player
var velocity = Vector3.ZERO
# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	global_transform.origin  += velocity * delta
	pass

func play_explode_animation():
	animation_player.play("explode")	
	

func _on_body_entered(body):
	if body.is_in_group("Player"):
		SignalBus.emit_signal("player_hit", damage_amount)
		
		#print("you got hit!!!!")
		#print("ya_got_hit")	
	if body.is_in_group("enemies"):
		SignalBus.emit_signal("enemy_hit", damage_amount, 1, body, 1)






func _on_explosion_animation_player_animation_finished(anim_name):
	#await $AudioStreamPlayer3D.finished
	$".".queue_free()
