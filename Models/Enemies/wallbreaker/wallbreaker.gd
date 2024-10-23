extends CharacterBody3D
@onready var nav_agent = $NavigationAgent3D
@export var SPEED = 5.0

@export var max_health: int = 100
var health_hp: int
@export var damage = 70

@onready var hitbox_position = %hitbox
@onready var x_axis = %x_axis

@onready var x_axis_shield = %x_axis_shield


@onready var Animation_Player = %AnimationPlayer
var explosion = preload("res://Scenes/Assets/projectiles/explosion.tscn")



var curr_state = "idle"
var next_state = "chase"
var prev_state
var target
var offset
var target_pos

var state_lock_on = false
var has_exploded = false

@onready var vision = %Vision
@onready var hitbox = $"."

func _ready():
	health_hp = max_health
	SignalBus.connect("enemy_hit", on_hit)
	
func _physics_process(delta):
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
		has_exploded = true
		var explosion_instance = explosion.instantiate()

		explosion_instance.damage_amount = damage

		$AudioStreamPlayer3D2.play()
		explosion_instance.global_transform.origin = hitbox.global_transform.origin
		var spawn_pos = hitbox.global_transform.origin
		spawn_pos.y += -1

		
		get_parent().add_child(explosion_instance)
		explosion_instance.play_explode_animation()
		hide()
		await explosion_instance.animation_player.animation_finished
		await $AudioStreamPlayer3D2.finished
		SignalBus.emit_signal("enemy_death")
		$".".queue_free()
		pass


func take_damage(amount: int):
	health_hp -= amount
	if health_hp <= 0:
		$".".hide()
		explode()
		

func on_hit(damage_taken, collider):
	if collider == hitbox:
		$AudioStreamPlayer3D.play()


		await get_tree().create_timer(.1).timeout


		take_damage(damage_taken)
	
	pass





func _on_animation_player_animation_finished(anim_name):
	if anim_name == "explode":
		return true


func _on_explode_radius_body_entered(body):
	if body.is_in_group("Player"):
		next_state = "explode"
