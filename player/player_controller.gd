extends CharacterBody3D

class_name Player

@export var look_sens: float = 0.006
@export var jump_velocity := 6.0
@export var bhop_on := true
@export var walk_speed := 7.0

@export var HEADBOB_SWAY_AMOUNT = 0.05
@export var HEADBOB_FREQ = 1
var headbob_time = 0.0

@export var air_cap := 0.85
@export var air_accel := 880.0
@export var air_move_speed := 500.0

#@export var gun_bobbing_amplitude := 0.002
#@export var gun_bobbing_frequency := 1

#@onready var gun:Node3D = $Head/Camera3D/Weapons_Manager/WeaponRig/smgModel/smgModel
@onready var mainCam = $Head/Camera3D
@onready var gunCam = $Head/Camera3D/SubViewportContainer/SubViewport/GunCam
@onready var dash_length_timer := $Timers/DashLength
@onready var dash_cooldown_timer := $Timers/DashCooldown

var wish_dir := Vector3.ZERO

var can_dash : bool = true
var is_dashing : bool = false

@export var dash_speed := 20.0  

func get_move_speed() -> float:
	return walk_speed

func _ready():
	for child in %WorldModel.find_children("*", "VisualInstance3D"):
		child.set_layer_mask_value(1, false)
		child.set_layer_mask_value(2, true)

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
	self.velocity.y -= ProjectSettings.get_setting("physics/3d/default_gravity") * delta
	
	var cur_speed_in_wish_dir = self.velocity.dot(wish_dir)
	
	var max_speed = min((air_move_speed * wish_dir).length(), air_cap)
	
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
	
	if is_on_floor():
		if Input.is_action_just_pressed("jump"):
			self.velocity.y = jump_velocity
		_handle_ground_physics(delta)
	else:
		_handle_air_physics(delta)
		
	if Input.is_action_just_pressed("Dash") and can_dash:
		_start_dash()
	if is_dashing:
		_apply_dash()
	
	move_and_slide()

func _start_dash():
	can_dash = false
	is_dashing = true
	dash_cooldown_timer.start()
	dash_length_timer.start()

func _apply_dash():
	var dash_direction = wish_dir
	if dash_direction.length() == 0: # if the player is not pressing any movement key (WASD), dash forward
		dash_direction = -global_transform.basis.z  

	velocity = dash_direction.normalized() * dash_speed

func _on_dash_length_timeout():
	is_dashing = false

func _on_dash_cooldown_timeout():
	can_dash = true
