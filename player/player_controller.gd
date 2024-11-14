extends CharacterBody3D

class_name Player

signal on_health_change(current: int, max: int)
signal on_shield_change(current: int, max: int)
signal on_take_damage()
signal on_die()

enum PostDeath{DestroyNode, RestartScene}

@export var post_death_action: PostDeath

@export var max_shield_hp: int = 100
@export var max_health_hp: int = 50

var shield_hp: int
var health_hp: int

var playing_shield_hurt = false
var playing_health_hurt = false
@export var camera_fov: int = 90
@export var gun_cam_fov: int = 75

@export var shield_regen_amount: float = 10
@export var health_regen_amount: float = 5
@export var look_sens: float = 0.006
@export var jump_velocity := 9.0
@export var bhop_on := true
@export var walk_speed := 9.0

@export var HEADBOB_SWAY_AMOUNT = 0.05
@export var HEADBOB_FREQ = 1
var headbob_time = 0.0

@export var air_cap := 5
@export var air_accel := 20.0
@export var air_move_speed := 300.0

@export var dash_speed := 7000.0

#@export var gun_bobbing_amplitude := 0.002
#@export var gun_bobbing_frequency := 1

#@onready var gun:Node3D = $Head/Camera3D/Weapons_Manager/WeaponRig/smgModel/smgModel
@onready var mainCam = $Head/Camera3D
@onready var gunCam = $Head/Camera3D/SubViewportContainer/SubViewport/GunCam

@export var shield_regen_timer_length: int = 5
@export var health_regen_timer_length: int = 8

@onready var shield_regen_timer = $shield_regen_timer
@onready var health_regen_timer = $health_regen_timer
@onready var dash_length_timer := $Timers/DashLength
@onready var dash_cooldown_timer := $Timers/DashCooldown
@onready var shield_deplete_sound := $shield_deplete_sound
@onready var hud = $Head/Camera3D/HUD

# The direction which the player "wishes" to move (according to WASD keys)

var wish_dir := Vector3.ZERO

var can_dash : bool = true
var is_dashing : bool = false
var dash_tween: Tween
var dash_velocity := Vector3.ZERO
var can_regen_health : bool = false
var can_regen_shield : bool = false


func get_move_speed() -> float:
	return walk_speed

func _ready():
	
	shield_hp = max_shield_hp
	health_hp = max_health_hp
	for child in %WorldModel.find_children("*", "VisualInstance3D"):
		child.set_layer_mask_value(1, false)
		child.set_layer_mask_value(2, true)
	
	hud.hud_initialize_player(shield_hp, health_hp)
	SignalBus.connect("player_hit", _on_player_hit)
	
	shield_regen_timer.wait_time = shield_regen_timer_length
	health_regen_timer.wait_time = health_regen_timer_length
	
	shield_regen_timer.connect("timeout", _on_shield_regen_timer_timeout)
	health_regen_timer.connect("timeout", _on_health_regen_timer_timeout)
	dash_length_timer.connect("timeout", _on_dash_length_timeout)
	dash_cooldown_timer.connect("timeout", _on_dash_cooldown_timeout)
	
	%Camera3D.fov = camera_fov
	%GunCam.fov = gun_cam_fov
	

func _unhandled_input(event):
	if event is InputEventMouseButton:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		if event is InputEventMouseMotion:
			rotate_y(-event.relative.x * look_sens)
			%Camera3D.rotate_x(-event.relative.y * look_sens)
			%Camera3D.rotation.x = clamp(%Camera3D.rotation.x, deg_to_rad(-90), deg_to_rad(90))

func _headbob_effect(delta):
	if self.velocity.length() > 0:
		headbob_time += delta * self.velocity.length()
	var sway_x = cos(headbob_time * HEADBOB_FREQ * 0.5) * HEADBOB_SWAY_AMOUNT
	var sway_y = sin(headbob_time * HEADBOB_FREQ) * HEADBOB_SWAY_AMOUNT
		
	%Camera3D.position += Vector3(sway_x, sway_y, 0)

 		#var gun_bob_offset = Vector3(0, sin(headbob_time * gun_bobbing_frequency) * gun_bobbing_amplitude, 0)
 		#gun.position += gun_bob_offset
	
func _process(delta):
	gunCam.global_transform = mainCam.global_transform
	pass

func _handle_air_physics(delta) -> void:
	# Apply gravity
	self.velocity.y -= PhysicsServer3D.area_get_param(get_viewport().find_world_3d().space, PhysicsServer3D.AREA_PARAM_GRAVITY) * delta
	# self.velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	
	# Normalize wish_dir to prevent faster diagonal movement

	wish_dir = wish_dir.normalized()

	var cur_speed_in_wish_dir = self.velocity.dot(wish_dir)

	var max_speed = min(air_move_speed, air_cap)

	var add_speed_till_max = max_speed - cur_speed_in_wish_dir
	if add_speed_till_max > 0:
		var accel_speed = air_accel * air_move_speed * delta
		accel_speed = min(accel_speed, add_speed_till_max)
		self.velocity += accel_speed * wish_dir
	
func _handle_ground_physics(delta) -> void:
	self.velocity.x = wish_dir.x * get_move_speed()
	self.velocity.z = wish_dir.z * get_move_speed()
	# _headbob_effect(delta)
	
func _physics_process(delta):
	var input_dir = Input.get_vector("left", "right", "up", "down").normalized()
	wish_dir = self.global_transform.basis * Vector3(input_dir.x, 0., input_dir.y)
	if can_regen_health:
		regen_health(health_regen_amount)
	if can_regen_shield:
		regen_shield(shield_regen_amount)
	
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			self.velocity.y = jump_velocity
		_handle_ground_physics(delta)
	else:
		_handle_air_physics(delta)
		
	_handle_dash_logic()
	
	move_and_slide()
	
func get_current_weapon():
	return $"Head/Camera3D/weapon manager".current_weapon
func get_other_weapon():
	return $"Head/Camera3D/weapon manager".other_weapon
	
func _on_player_hit(damage_amount):
	#print("Damage Amount: " + str(damage_amount))
	if not is_dashing:
		
		var shield_amount = int($Head/Camera3D/HUD/player_info/shield/shield_amount.text)
		var health_amount = int($Head/Camera3D/HUD/player_info/health/health_amount.text)
		
		can_regen_shield = false
		can_regen_health = false
		shield_regen_timer.start()
		if shield_hp <= 0:
			%hurt.stop()
			%hurt.play("health_hurt")
			health_regen_timer.start()
		else:
			%hurt.play("shield_hurt")
		take_damage(damage_amount)
		hud.update_shield_and_health(shield_hp, health_hp)

	
func game_over():
	get_tree().reload_current_scene()

func take_damage(amount: int):
	if shield_hp <= 0:
		health_hp -= amount
		on_health_change.emit(health_hp, max_health_hp)
		on_take_damage.emit()
	else:
		shield_hp -= amount
		shield_hp = max(shield_hp, 0)
		if shield_hp == 0:
			shield_deplete_sound.play()
	if health_hp <= 0:
		game_over()
	pass

func regen_shield(amount: int):
	shield_hp += amount
	if shield_hp >= max_shield_hp:
		shield_hp = max_shield_hp
		can_regen_shield = false
	on_shield_change.emit(shield_hp, max_shield_hp)
	hud.update_shield_and_health(shield_hp, health_hp)
	pass
	
func regen_health(amount: int):
	health_hp += amount
	if health_hp >= max_health_hp:
		health_hp = max_health_hp
		can_regen_health = false
	on_health_change.emit(health_hp, max_shield_hp)
	hud.update_shield_and_health(shield_hp, health_hp)


func _handle_dash_logic():
	if Input.is_action_just_pressed("Dash") and can_dash:
		_start_dash()
	if is_dashing:
		_apply_dash()

func _start_dash():
	can_dash = false
	is_dashing = true
	dash_cooldown_timer.start()
	dash_length_timer.start()
	
	var dash_direction = wish_dir
	dash_direction = dash_direction.normalized()
	if dash_tween:
		dash_tween.kill()  # Stop any existing tween
	dash_tween = create_tween()
	dash_tween.set_ease(Tween.EASE_IN)
	dash_tween.set_trans(Tween.TRANS_BOUNCE)
	
	# Tween the dash velocity
	dash_velocity = dash_direction * dash_speed
	dash_tween.tween_property(self, "dash_velocity", dash_direction * (dash_speed * 0.1), dash_length_timer.wait_time)

func _apply_dash():
	var dash_direction := wish_dir
	if dash_direction.length() == 0: # if the player is not pressing any movement key (WASD), dash forward
		dash_direction = -global_transform.basis.z
	
	self.velocity = dash_direction.normalized() * dash_speed

func _on_dash_length_timeout():
	is_dashing = false

func _on_dash_cooldown_timeout():
	can_dash = true


func _on_shield_regen_timer_timeout():
	can_regen_shield = true



func _on_health_regen_timer_timeout():
	can_regen_health = true
