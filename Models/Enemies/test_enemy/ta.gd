extends Node3D

@onready var rng = RandomNumberGenerator.new()
@onready var face_target_y = $f_t_y
@onready var face_target_x = $f_t_y/f_t_x
@onready var Animation_Player = get_node("AnimationPlayer")
var target : Node3D
var target_pos
var enemy
var can_move = false
var in_chill = false

@onready var laser = %Laser

var health = 10
#@onready var speed = face_target_y.follow_speed
@onready var speed = rng.randf_range(0.02,0.05)
@onready var non_flame_y = $f_t_y/f_t_y_model_group/non_flame_y
@onready var f_t_y_shield = $f_t_y/f_t_y_shield
@onready var non_face_x = $f_t_y/f_t_x/f_t_x_model_group/non_face_x
@onready var f_t_x_shield = $f_t_y/f_t_x/f_t_x_shield
var in_chase = false


func _ready():
	speed = rng.randf_range(0.02,0.05)
	enemy = $CharacterBody3D
	laser.player = get_tree().get_nodes_in_group("Player")[0]
	pass
	
func face_target(target_pos, delta):
	target_pos = target.global_transform.origin + Vector3(0,1.5,0)
	face_target_y.face_point(target_pos, delta)
	face_target_x.face_point(target_pos, delta)
	
	if face_target_x.is_facing_target(target_pos):
		laser.show()
		laser.laser_state = "active"
func _physics_process(delta):
	if target:
		face_target(target_pos, delta)
func show_angry():
	$f_t_y/f_t_x/f_t_x_model_group/Angry_Face.show()
	$f_t_y/f_t_y_model_group/Angry_Flame.show()
	$f_t_y/f_t_x/f_t_x_model_group/Mellow_Face.hide()
	$f_t_y/f_t_y_model_group/Mellow_Flame.hide()
	

func show_happy():
	$f_t_y/f_t_x/f_t_x_model_group/Angry_Face.hide()
	$f_t_y/f_t_y_model_group/Angry_Flame.hide()
	$f_t_y/f_t_x/f_t_x_model_group/Mellow_Face.show()
	$f_t_y/f_t_y_model_group/Mellow_Flame.show()




func _on_weapons_manager_hit(tar):
	if tar == enemy and can_move:
		print("HITTTTT")
		$AudioStreamPlayer3D.play()
		non_flame_y.hide()
		non_face_x.hide()
		f_t_y_shield.show()
		f_t_x_shield.show()
		await get_tree().create_timer(.1).timeout
		non_flame_y.show()
		non_face_x.show()
		f_t_y_shield.hide()
		f_t_x_shield.hide()
		
		health -= 1
		if health == 0:
			Animation_Player.queue("explosion")
			await Animation_Player.animation_finished
			$".".queue_free()
	
	pass # Replace with function body.


func _on_chase_body_entered(body):
	if !in_chill and body.is_in_group("Player"):
		in_chase = true
		target = body
		print("IN")
	pass # Replace with function body.


func _on_chase_body_exited(body):
	if body.is_in_group("Player"):
		in_chase = false
		target = null
		print("OUT")
		laser.laser_state = "none"
		laser.hide()
		show_happy()
	elif in_chill and body.is_in_group("Player"):
		in_chase = true
		target= body
	pass # Replace with function body.
	
	


func _on_chill_body_entered(body):
	if body.is_in_group("Player"):
		in_chase = false
		in_chill = true
		print("CHILL IN")
	pass # Replace with function body.


#func _on_chill_body_exited(body):
	#if body.is_in_group("Player"):
		#in_chase = true
		#print("CHILL OUT")
	#pass # Replace with function body.
