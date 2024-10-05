extends CharacterBody3D
@onready var nav_agent = $NavigationAgent3D
@export var SPEED = 5.0
@export var health = 10
@export var damage = 1
@export var projectile_speed = 5
@export var firing_speed_in_seconds = 2
@export var visibility_range = 1000000


@onready var face_target_y = $f_t_y
@onready var face_target_x = $f_t_y/f_t_x
@onready var f_t_y_shield = %f_t_y_shield
@onready var f_t_x_shield = $f_t_y/f_t_x/f_t_x_shield

@onready var Animation_Player = get_node("AnimationPlayer")

@onready var timer = $Timer


var timer_started = false
var is_firing = false

@onready var projectile_origin_spot = $f_t_y/f_t_x/Marker3D
var projectile = preload("res://Scenes/Assets/projectiles/enemy_projectile.tscn")
var curr_state = "idle"
var next_state = "idle"
var prev_state
var target
var offset
var target_pos
@onready var hitbox = $"."

func _ready():
	offset = add_rand_offset(2)
	timer.wait_time = firing_speed_in_seconds
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
			

func idle():
	#print("idling")
	velocity = Vector3.ZERO
	move_and_slide()

func chase(delta):
	target = get_tree().get_nodes_in_group("Player")[0]
	
	target_pos = target.global_transform.origin
	face_target_y.face_point(target_pos, delta)
	face_target_x.face_point(target_pos, delta)
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized() * SPEED

	nav_agent.set_velocity(new_velocity)
	if can_see_player(target):
		shoot(timer)
	


func retreat(delta):
	target = get_tree().get_nodes_in_group("Player")[0]
	offset = add_rand_offset(randf_range(-5, 5))
	target_pos = target.global_transform.origin
	face_target_y.face_point(target_pos, delta)
	face_target_x.face_point(target_pos, delta)
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized() * SPEED

	nav_agent.set_velocity(-new_velocity)
	
	shoot(timer)

func no_move_debug(delta):
	target_pos = target.global_transform.origin
	face_target_y.face_point(target_pos, delta)
	face_target_x.face_point(target_pos, delta)
	shoot(timer)

func _on_chase_body_entered(body):
	if body.is_in_group("Player"):
		next_state = "chase"
		

func shoot(tm):
	if face_target_x.is_facing_target(target_pos) and not is_firing:
		tm.start()
		is_firing = true
		Animation_Player.queue("smt_shoot")
		$AudioStreamPlayer3D2.play()
		
		var projectile_instance = projectile.instantiate()

		projectile_instance.damage_amount = damage

		
		projectile_instance.global_transform.origin = projectile_origin_spot.global_transform.origin
		var spawn_pos = projectile_origin_spot.global_transform.origin
		spawn_pos.y += -1

		var direction = (target_pos - spawn_pos).normalized()  
		projectile_instance.velocity = direction * projectile_speed  


		get_parent().add_child(projectile_instance)
		

	

func _on_chill_body_entered(body):
	if body.is_in_group("Player"):
		next_state = "retreat" 
		



func _on_chase_body_exited(body):
	if body.is_in_group("Player"):
		next_state = "chase"




func _on_weapons_manager_hit(tar):
	if tar == hitbox:
			#print("HITTTTT")
			$AudioStreamPlayer3D.play()
			f_t_y_shield.show()
			f_t_x_shield.show()
			await get_tree().create_timer(.1).timeout
			f_t_y_shield.hide()
			f_t_x_shield.hide()
			
			health -= 1
			if health == 0:
				#Animation_Player.queue("explosion")
				#await Animation_Player.animation_finished
				$".".queue_free()
				SignalBus.emit_signal("enemy_death")
		

	pass # Replace with function body.


func _on_timer_timeout():
	is_firing = false
	pass # Replace with function body.

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

func can_see_player(plr) -> bool:
	var dir = (plr.global_position - $".".global_position).normalized()
	var forward_dir = $".".transform.basis.z
	var dot_product = dir.dot(forward_dir)
	
	if dot_product < visibility_range and is_player_visible(plr):
		return true
	else:
		#print("huh?")
		return false
	return false
		
