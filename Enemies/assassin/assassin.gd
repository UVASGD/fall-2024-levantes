extends CharacterBody3D
@onready var nav_agent = $NavigationAgent3D

@export var set_next_state: String
@export var SPEED = 5.0
@export var speed_when_attacking = 10.0
@export var retreat_speed = 10.0
var chase_speed = SPEED
var is_dead = false
@export var gun_path: String
@export var max_health: int = 100
var health_hp: int
@export var damage = 15
@export var visibility_range = 1000000

@onready var assassin_animation_player : AnimationPlayer = $x_axis/x_axis_model_group/AssassinRig/AnimationPlayer

@onready var x_axis = %x_axis
@onready var y_axis = %y_axis


@onready var Animation_Player = get_node("AnimationPlayer")

@onready var timer = $Timer
@onready var vision_timer = $VisionTimer

@onready var knife = %MeleeKnife

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

var lock = false

var is_dying = false

@onready var vision = %Vision
@onready var collider = $"."
@onready var hitbox = %hitbox
@onready var head_hitbox = $"../Area3D"

func _ready():
	if set_next_state:
		next_state = set_next_state
	offset = add_rand_offset(2)
	health_hp = max_health
	SignalBus.connect("enemy_hit", on_hit)
	vision_timer.connect("timeout", _on_vision_timer_timeout)
	SignalBus.connect("few_enemies", show_indicator)
	
func _physics_process(delta):
	if not self.is_on_floor():
		self.velocity.y += get_gravity().y * delta
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
			"melee":
				melee(delta)
	
func show_indicator():
	%indicator.visible = true
	
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
			#SPEED = chase_speed
			velocity = velocity.move_toward(safe_velocity+offset, 0.25)
			move_and_slide()
		"retreat":
			velocity = velocity.move_toward(safe_velocity+offset, 0.25)
			move_and_slide()
		"melee":
			#velocity = velocity.move_toward(safe_velocity, 0.25)
			velocity = velocity.move_toward(safe_velocity, 0.25)
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
	assassin_animation_player.play("Floating")

	nav_agent.set_velocity(new_velocity)

func melee(delta):
	face_target(delta)
	if not lock:
		lock = true
		$attack.play()
		Animation_Player.play("attack_state")
		assassin_animation_player.play("Slash")
		await Animation_Player.animation_finished
		next_state = "retreat"
		lock = false
		knife.is_attacking = false
		


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

func on_hit(damage_taken, hs_mult, col, shape):
	#if not is_dying and (collider == hitbox or collider == head_hitbox):
	if not is_dying and col==collider and (shape == 1 or shape == 0):
		$AudioStreamPlayer3D.play()
		#x_axis_shield.show()
		#y_axis_shield.show()c
		Animation_Player.play("got_hit")
		#await get_tree().create_timer(.1).timeout
		#x_axis_shield.hide()
		#y_axis_shield.hide()
		
		var updated_dmg = damage_taken
		#if collider == head_hitbox:
		if shape == 0:
			updated_dmg *= hs_mult
		take_damage(updated_dmg)

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
	if is_dead:
		return
	$death.play()
	is_dead = true
	spawn_reward()
	next_state = "idle"
	Animation_Player.play("death")
	await Animation_Player.animation_finished
	$".".queue_free()
	SignalBus.emit_signal("enemy_death")
	pass

func spawn_reward():
	var num = randi_range(0,9)
	print("generated num: " + str(num))
	var instance
	if num >= 7:
		instance = load(gun_path).instantiate()
	else: #better luck next time
		return
	get_tree().root.add_child(instance)
	instance.position = self.position + Vector3(0,0,1)
	return
	
func _on_animation_player_animation_finished(anim_name):
	pass # Replace with function body.


func _on_melee_body_entered(body):
	if body.is_in_group("Player"):
		next_state = "melee"
