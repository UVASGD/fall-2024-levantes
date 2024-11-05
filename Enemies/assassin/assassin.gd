extends CharacterBody3D
@onready var nav_agent = $NavigationAgent3D

@export var set_next_state: String
@export var SPEED = 5.0

@export var max_health: int = 100
var health_hp: int
@export var damage = 15
@export var visibility_range = 1000000


@onready var x_axis = %x_axis
@onready var y_axis = %y_axis


@onready var Animation_Player = get_node("AnimationPlayer")

@onready var timer = $Timer
@onready var vision_timer = $VisionTimer

var vision_timer_done = false
var is_firing = false
var can_move_y_axis = false


var curr_state = "idle"
var next_state = "idle"
var prev_state
var target
var offset
var target_pos

var is_invis = false

var is_dying = false

@onready var vision = %Vision
@onready var hitbox = $"."

func _ready():
	if set_next_state:
		next_state = set_next_state
	offset = add_rand_offset(2)
	health_hp = max_health
	SignalBus.connect("enemy_hit", on_hit)
	vision_timer.connect("timeout", _on_vision_timer_timeout)
	
func _physics_process(delta):
	prev_state = curr_state
	curr_state = next_state
	
	if not is_dying:
		match curr_state:
			"idle":
				idle()
			"chase":
				chase(delta)
			"retreat":
				retreat(delta)
			"no_move_debug":
				no_move_debug(delta)
	

func update_target_location(target_location):
	nav_agent.target_position = target_location
	
func add_rand_offset(offset_amount) -> Vector3:
	var offset = Vector3(randf() - offset_amount, 0, randf() - offset_amount).normalized() * offset_amount
	return offset

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
			
func face_target(delta):
	target_pos = target.global_transform.origin + Vector3(0,1.5,0)
	
	x_axis.current_turn_speed = x_axis.normal_turn_speed
	x_axis.face_point(target_pos, delta)
	
	if can_move_y_axis:
		y_axis.current_turn_speed = y_axis.normal_turn_speed
		y_axis.face_point(target_pos, delta)

func update_turn_speed(new_speed):
	x_axis.current_turn_speed = new_speed
	y_axis.current_turn_speed = new_speed

func idle():
	#print("idling")
	velocity = Vector3.ZERO
	move_and_slide()

func chase(delta):
	if not is_invis:
		is_invis = true
		Animation_Player.play("enter_cloak_state")
	target = get_tree().get_nodes_in_group("Player")[0]
	#_i_can_see()
	face_target(delta)
	
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized() * SPEED

	nav_agent.set_velocity(new_velocity)

	


func retreat(delta):
	target = get_tree().get_nodes_in_group("Player")[0]
	offset = add_rand_offset(randf_range(-5, 5))
	face_target(delta)
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized() * SPEED

	nav_agent.set_velocity(-new_velocity)


func no_move_debug(delta):
	target_pos = target.global_transform.origin
	x_axis.face_point(target_pos, delta)
	y_axis.face_point(target_pos, delta)


func _on_chase_body_entered(body):
	if body.is_in_group("Player"):
		next_state = "chase"

func _on_chase_body_exited(body):
	if body.is_in_group("Player"):
		next_state = "chase"

func take_damage(amount: int):
	health_hp -= amount
	if health_hp <= 0:
		is_dying = true
		death()

func on_hit(damage_taken, collider):
	if not is_dying and collider == hitbox:
		$AudioStreamPlayer3D.play()


		await get_tree().create_timer(.1).timeout


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
						var new_turn_speed = y_axis.current_turn_speed + 100
						update_turn_speed(new_turn_speed)
						return false
			elif overlap.is_in_group("Player") and is_player_visible(overlap):
				vision_timer.start()
				update_turn_speed(y_axis.normal_turn_speed)
				return true
	return false

	
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




func _on_vision_body_entered(body):
	if body.is_in_group("Player"):
		can_move_y_axis = true


func _on_vision_body_exited(body):
	if body.is_in_group("Player"):
		can_move_y_axis = false

func death():
	next_state = "idle"
	#Animation_Player.play("smt_death")
	#await Animation_Player.animation_finished
	$".".queue_free()
	SignalBus.emit_signal("enemy_death")
	pass

func _on_animation_player_animation_finished(anim_name):
	pass # Replace with function body.
