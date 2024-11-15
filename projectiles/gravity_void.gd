extends Node3D 
signal ya_got_hit

@export var damage_amount = 35
@onready var timer = $Timer
@onready var animation_player = $explosion_animation_player

var velocity = Vector3.ZERO

func _ready():
	$Area3D.connect("body_entered", _on_body_entered)

func _process(float):
	for collider in $Area3D.get_overlapping_bodies():
		if collider is RigidBody3D or collider is CharacterBody3D:
			_apply_gravity_force(collider)
		

func _on_body_entered(body):
	# Ensure the body is a RigidBody3D to apply forces to it
	if body is RigidBody3D:
		_apply_gravity_force(body)

# Custom function to apply gravity force to the body
func _apply_gravity_force(body):
	var direction = (global_transform.origin - body.global_transform.origin).normalized()
	var gravity_strength = 0.3
	if body is RigidBody3D:
		body.apply_central_force(direction * gravity_strength * body.mass)
	else:
		body.velocity += direction * gravity_strength

func play_explode_animation():
	animation_player.play("explode")
	#$AudioStreamPlayer3D.play()



func _on_explosion_animation_player_animation_finished(anim_name):
	#await $AudioStreamPlayer3D.finished
	$".".queue_free()
