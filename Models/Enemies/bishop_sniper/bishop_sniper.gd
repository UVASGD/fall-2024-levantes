extends CharacterBody3D
@onready var nav_agent = $NavigationAgent3D
@export var SPEED = 10

@export var max_health: int = 100
var health_hp: int
@export var damage = 1
@export var projectile_speed = 5
@export var firing_speed_in_seconds = 2
@export var visibility_range = 1000000


@onready var x_axis = %x_axis
@onready var y_axis = %y_axis

@onready var x_axis_model_group = %x_axis_model_group
@onready var y_axis_model_group = %y_axis_model_group

@onready var x_axis_shield = %x_axis_shield
@onready var y_axis_shield = %y_axis_shield

@onready var Animation_Player = get_node("AnimationPlayer")

@onready var timer = $Timer
@onready var vision_timer = $VisionTimer


var vision_timer_done = false
var is_firing = false

@onready var laser = %Laser

var curr_state = "idle"
var next_state = "idle"
var prev_state
var target
var offset
var target_pos

var in_firing_state = false

var animation_lock_on = false

var can_move_y_axis = false
@onready var hitbox = $"."
@onready var vision = %Vision

func _ready():
	offset = add_rand_offset(2)
	timer.wait_time = firing_speed_in_seconds
	health_hp = max_health
	SignalBus.connect("enemy_hit", on_hit)
	vision_timer.connect("timeout", _on_vision_timer_timeout)
	Animation_Player.connect("animation_finished", _animation_player_finished)
	laser.player = get_tree().get_nodes_in_group("Player")[0]
	
func _physics_process(delta):
	prev_state = curr_state
	curr_state = next_state
	
	
	match curr_state:
		"idle":
			idle()
		"chase":
			chase(delta)
		"retreat":
			retreat(delta)
		"no_move_debug":
			no_move_debug(delta)
		"sight_on":
			sight_on(delta)
	

func update_target_location(target_location):
	nav_agent.target_position = target_location
	
func add_rand_offset(offset_amount) -> Vector3:
	var offset = Vector3(randf() - offset_amount, 0, randf() - offset_amount).normalized() * offset_amount
	return offset
	
func face_target(delta):
	target_pos = target.global_transform.origin + Vector3(0,1.2,0)
	
	update_turn_speed(x_axis.normal_turn_speed)
	x_axis.face_point(target_pos, delta)
	
	if can_move_y_axis:
		show_laser()
		y_axis.face_point(target_pos, delta)
		
func update_turn_speed(new_speed):
	x_axis.current_turn_speed = new_speed
	y_axis.current_turn_speed = new_speed
func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	match curr_state:
		"idle":
			velocity = Vector3.ZERO
			move_and_slide()
		"chase":
			velocity = velocity.move_toward(safe_velocity+offset, 0.25)
			move_and_slide()
		"retreat":
			velocity = velocity.move_toward(safe_velocity+offset, 0.25)
			move_and_slide()
			
			

func idle():
	velocity = Vector3.ZERO
	move_and_slide()

func chase(delta):
	target = get_tree().get_nodes_in_group("Player")[0]
	
	
	face_target(delta)
	update_turn_speed(y_axis.normal_turn_speed)
	
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized() * SPEED

	nav_agent.set_velocity(new_velocity)
	hide_laser()
	

func sight_on(delta):
	
	target = get_tree().get_nodes_in_group("Player")[0]
	#_i_can_see()
	target_pos = target.global_transform.origin
	
	face_target(delta)
	update_turn_speed(y_axis.normal_turn_speed - 20)
	#TODO: Use x_axis.face_point and y_axis.face_point to make the 
	# 	   enemy face the player and make them enter a shoot state
	pass
func retreat(delta):
	hide_laser()
	target = get_tree().get_nodes_in_group("Player")[0]
	offset = add_rand_offset(randf_range(-5, 5))
	target_pos = target.global_transform.origin
	
	face_target(delta)
	
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized() * SPEED

	nav_agent.set_velocity(-new_velocity)


func no_move_debug(delta):
	target_pos = target.global_transform.origin
	x_axis.face_point(target_pos, delta)
	y_axis.face_point(target_pos, delta)
	shoot(timer)

		
# TODO: Make the enemy shoot a laser beam from the muzzle to the player instead of just a enemy projectile
#		This probably involves making a new projectile, look at enemy_projectile scene and gd script file for that
func shoot(tm):
	pass
	




	

func take_damage(amount: int):
	health_hp -= amount
	if health_hp <= 0:
		$".".queue_free()
		SignalBus.emit_signal("enemy_death")

func on_hit(damage_taken, collider):
	if collider == hitbox:
		$AudioStreamPlayer3D.play()
		x_axis_model_group.hide()
		y_axis_model_group.hide()
		x_axis_shield.show()
		y_axis_shield.show()
		await get_tree().create_timer(.1).timeout
		x_axis_shield.hide()
		y_axis_shield.hide()
		x_axis_model_group.show()
		y_axis_model_group.show()
		take_damage(damage_taken)
	
	pass

func can_enemy_see_player() -> bool:
	var overlaps = vision.get_overlapping_bodies()
	if overlaps.size() > 0:
		for overlap in overlaps:
			if overlap.is_in_group("Player") and vision_timer_done:
				match is_player_visible(overlap):
					true:
						update_turn_speed(y_axis.normal_turn_speed)
						return true
					false:
						update_turn_speed(y_axis.current_turn_speed + 100)
						return false
			elif overlap.is_in_group("Player") and is_player_visible(overlap):
				vision_timer.start()
				update_turn_speed(y_axis.normal_turn_speed)
				return true
	return false

func _on_timer_timeout():
	is_firing = false
	pass # Replace with function body.
	
func _on_vision_timer_timeout():
	vision_timer_done = true 

func is_player_visible(plr) -> bool:
	var cone_angle = deg_to_rad(45)  # 45 degree cone angle (adjust as needed)
	var num_rays = 10  # Number of rays for simulating the cone
	
	
	var space_state = get_world_3d().direct_space_state
	var from = $".".global_position
	var to = plr.global_position
	var query = PhysicsRayQueryParameters3D.create(from, to, 1, [self])
	var result = space_state.intersect_ray(query)
	if result:
		if result.collider is Player:
			return true
		else:
			return false
	else:
		return false


func show_laser():
	await get_tree().create_timer(0.1).timeout
	laser.show()
	laser.laser_state = "active"

func hide_laser():
	laser.hide()
	laser.laser_state = "none"


func _on_retreat_body_entered(body):
	if body.is_in_group("Player"):
		next_state = "retreat"
		hide_laser()
		Animation_Player.play_backwards("enter_shoot_state")
		



func _on_enter_body_entered(body):
	if body.is_in_group("Player"):
		next_state = "sight_on"
		Animation_Player.queue("enter_shoot_state")
		show_laser()




func _on_retreat_body_exited(body):
	if body.is_in_group("Player"):
		next_state = "sight_on"
		Animation_Player.queue("enter_shoot_state")
		show_laser()


func _on_enter_body_exited(body):
	if body.is_in_group("Player"):
		next_state = "chase"
		hide_laser()
		Animation_Player.play_backwards("enter_shoot_state")

func _animation_player_finished():
	return true


func _on_vision_body_entered(body):
	if body.is_in_group("Player"):
		can_move_y_axis = true


func _on_vision_body_exited(body):
	if body.is_in_group("Player"):
		can_move_y_axis = false
		



func _on_animation_player_animation_finished(anim_name):
	pass
		
