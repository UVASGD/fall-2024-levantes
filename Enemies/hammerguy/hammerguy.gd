extends CharacterBody3D
@onready var nav_agent = $NavigationAgent3D
@export var gun_path: String
@export var set_next_state: String
@export var SPEED:int
@export var shots_per_burst = 3
@export var time_between_each_shot = 0.1
@export var max_spread_deviaton_degs: float = 1.2

@export var max_health: int = 100
var health_hp: int
@export var damage = 15
@export var projectile_speed = 5
@export var min_firing_speed_in_seconds = 1.5
@export var max_firing_speed_in_seconds = 2.0
@export var visibility_range = 1000000
@export var shots_per_shoot_call = 3

@onready var x_axis = %x_axis
@onready var y_axis = %y_axis
@onready var timer = $Timer
@onready var Animation_Player = $AnimationPlayer


@onready var vision_timer = $VisionTimer
var ring = preload("res://projectiles/shockwave.tscn")
var ammo_drop = preload("res://Weapons (new)/husk/ammo_drop.tscn")
var vision_timer_done = false
var is_firing = false
var can_move_y_axis = false
var is_anim_playing = false
var is_dead = false

var curr_state = "idle"
var next_state = "idle"
var prev_state
var target
var offset
var target_pos

var is_dying = false
var ring_exists = false
@onready var animtimer = $animtimer
@onready var vision = %Vision
@onready var hitbox = $"."

func _ready():
	if set_next_state:
		next_state = set_next_state
	offset = add_rand_offset(2)
	timer.wait_time = randf_range(min_firing_speed_in_seconds, max_firing_speed_in_seconds)
	health_hp = max_health
	SignalBus.connect("enemy_hit", on_hit)
	SignalBus.connect("shockwave_death", on_shockwave_death)
	vision_timer.connect("timeout", _on_vision_timer_timeout)
	
func _physics_process(delta):
	prev_state = curr_state
	curr_state = next_state
	print(curr_state)
	if not is_dying:
		match curr_state:
			"idle":
				idle()
			"chase":
				chase(delta)
			"retreat":
				retreat(delta)


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
	target = get_tree().get_nodes_in_group("Player")[0]
	#_i_can_see()
	face_target(delta)
	
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized() * SPEED

	nav_agent.set_velocity(new_velocity)
	if can_enemy_see_player():
		attack()
	


func retreat(delta):
	target = get_tree().get_nodes_in_group("Player")[0]
	offset = add_rand_offset(randf_range(-5, 5))
	face_target(delta)
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized() * SPEED

	nav_agent.set_velocity(-new_velocity)
	if can_enemy_see_player():
		attack()


func _on_chase_body_entered(body):
	if body.is_in_group("Player"):
		next_state = "chase"
		

func attack():
	if y_axis.is_facing_target(target_pos) and not is_firing and not is_dying and not ring_exists:
		is_firing = true
		Animation_Player.play("attack")
		await Animation_Player.animation_finished
		timer.start()
		await  timer.timeout
		is_firing = false


func create_danger_ring():
	if not ring_exists:
		ring_exists = true
		var instance = ring.instantiate()
		instance.damage = self.damage
		get_tree().root.add_child(instance)
		instance.transform.origin = self.transform.origin
	pass

func on_shockwave_death():
	ring_exists = false

func _on_chill_body_entered(body):
	if body.is_in_group("Player"):
		next_state = "retreat" 
		



func _on_chase_body_exited(body):
	if body.is_in_group("Player"):
		next_state = "chase"

func take_damage(amount: int):
	health_hp -= amount
	if health_hp <= 0:
		is_dying = true
		death()

func on_hit(damage_taken, collider):
	if not is_dying and collider == self:
		$AudioStreamPlayer3D.play()
		take_damage(damage_taken)
		print(health_hp)
	
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




func _on_vision_body_entered(body):
	if body.is_in_group("Player"):
		can_move_y_axis = true


func _on_vision_body_exited(body):
	if body.is_in_group("Player"):
		can_move_y_axis = false

func death():
	if is_dead:
		return
	is_dead = true
	spawn_reward()
	next_state = "idle"
	#Animation_Player.play("smt_death")
	#await Animation_Player.animation_finished
	$".".queue_free()
	SignalBus.emit_signal("enemy_death")
	pass

func spawn_reward():
	var num = randi_range(0,9)
	print("generated num: " + str(num))
	var instance
	if num >= 8:
		instance = load(gun_path).instantiate()
	elif num >= 4:
		instance = ammo_drop.instantiate()
	else: #better luck next time
		return
	get_tree().root.add_child(instance)
	instance.position = self.position + Vector3(0,0,1)
	return
	
func _on_animation_player_animation_finished(anim_name):
	is_anim_playing = false
	pass # Replace with function body.


func _on_chase_again_body_exited(body: Node3D) -> void:
	if body.is_in_group("Player"):
		next_state = "chase"
	pass # Replace with function body.
