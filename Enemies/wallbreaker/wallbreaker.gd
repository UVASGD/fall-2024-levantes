extends CharacterBody3D
@export var set_next_state: String
@onready var nav_agent = $NavigationAgent3D
@export var SPEED = 5.0
@export var gun_path: String
@export var max_health: int = 100
var health_hp: int
@export var damage = 70

@onready var hitbox_position = %hitbox
@onready var x_axis = %x_axis

@onready var x_axis_shield = %x_axis_shield


@onready var Animation_Player = %AnimationPlayer
@onready var hit_animation_player = $hit_animation_player
var explosion = preload("res://projectiles/explosion.tscn")



var curr_state = "idle"
var next_state = "chase"
var prev_state
var target
var offset
var target_pos
var playing_run_sound =  false
var state_lock_on = false
var has_exploded = false

@onready var vision = %Vision
@onready var hitbox = %hitbox
@onready var collider = $"."

func _ready():
	if set_next_state:
		next_state = set_next_state
	health_hp = max_health
	SignalBus.connect("enemy_hit", on_hit)
	SignalBus.connect("few_enemies", show_indicator)
	$run.connect("finished", on_run_sound_finished)
	
func _physics_process(delta):
	if not self.is_on_floor():
		self.velocity.y += get_gravity().y * delta
	prev_state = curr_state
	curr_state = next_state
	
	if not state_lock_on:
		match curr_state:
			"idle":
				idle()
			"chase":
				chase(delta)
			"explode":
				explode()

func on_run_sound_finished():
	playing_run_sound = false
func show_indicator():
	%indicator.visible = true
	
func update_target_location(target_location):
	nav_agent.target_position = target_location
	
func add_rand_offset(offset_amount) -> Vector3:
	var offset = Vector3(randf() - offset_amount, 0, randf() - offset_amount).normalized() * offset_amount
	return offset

func _on_navigation_agent_3d_velocity_computed(safe_velocity):
	if not state_lock_on:
		match curr_state:
			"idle":
				velocity = Vector3.ZERO
				move_and_slide()
			"chase":
				velocity = velocity.move_toward(safe_velocity, 0.25)
				move_and_slide()
			"explode":
				velocity = Vector3.ZERO
				move_and_slide()

func face_target(delta):
	target_pos = target.global_transform.origin + Vector3(0,1.5,0)
	
	x_axis.current_turn_speed = x_axis.normal_turn_speed
	x_axis.face_point(target_pos, delta)
	
func update_turn_speed(new_speed):
	x_axis.current_turn_speed = new_speed


func idle():
	#print("idling")
	velocity = Vector3.ZERO
	move_and_slide()

func chase(delta):
	if not playing_run_sound:
		playing_run_sound = true
		$run.play()
	Animation_Player.play("ArmatureAction")
	target = get_tree().get_nodes_in_group("Player")[0]
	#_i_can_see()
	face_target(delta)
	
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized() * SPEED

	nav_agent.set_velocity(new_velocity)

func explode():
	state_lock_on = true
	if not has_exploded:
		$run.stop()
		has_exploded = true
		Animation_Player.play("explode")
		await Animation_Player.animation_finished
		$".".hide()
		var explosion_instance = explosion.instantiate()

		explosion_instance.damage_amount = damage

		$AudioStreamPlayer3D2.play()
		explosion_instance.global_transform.origin = global_transform.origin
		var spawn_pos = global_transform.origin
		spawn_pos.y += -1


		
		get_parent().add_child(explosion_instance)
		explosion_instance.play_explode_animation()
		hide()
		await explosion_instance.animation_player.animation_finished
		await $AudioStreamPlayer3D2.finished
		spawn_reward()
		SignalBus.emit_signal("enemy_death")
		$".".queue_free()
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

func take_damage(amount: int):
	health_hp -= amount
	if health_hp <= 0:
		
		explode()
		

func on_hit(damage_taken, hs_mult, col, shape):
	#if not is_dying and (collider == hitbox or collider == head_hitbox):
	if col==collider and (shape == 1 or shape == 0):
		$AudioStreamPlayer3D.play()
		$hit_animation_player.play("got_hit")
		await get_tree().create_timer(.1).timeout
		
		var updated_dmg = damage_taken
		#if collider == head_hitbox:
		if shape == 0:
			updated_dmg *= hs_mult
		take_damage(updated_dmg)



func _on_animation_player_animation_finished(anim_name):
	pass


func _on_explode_radius_body_entered(body):
	if body.is_in_group("Player"):
		next_state = "explode"
