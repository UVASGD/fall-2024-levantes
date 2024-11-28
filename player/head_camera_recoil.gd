extends Node3D

@export var recoil_amount: Vector3
@export var snap_amount: float
@export var speed: float

var current_rotation: Vector3
var target_rotation: Vector3

func _ready() -> void:
	SignalBus.connect("weapon_fire_recoil", add_recoil)
	
func _process(delta: float) -> void:
	target_rotation = lerp(target_rotation, Vector3.ZERO, speed * delta)
	current_rotation = lerp(current_rotation, target_rotation, snap_amount * delta)
	basis = Quaternion.from_euler(current_rotation)
	
func add_recoil(r_amm:Vector3, s_amm:float, r_speed:float) -> void:
	target_rotation += Vector3(
		r_amm.x,
		randf_range(-r_amm.y, r_amm.y), 
		randf_range(-r_amm.z, r_amm.z)
	)
	snap_amount = s_amm
	speed = r_speed
	
