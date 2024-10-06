class_name husk_weapon
extends RigidBody3D


@export var weapon_name: String
@export var current_ammo: int
@export var reserve_ammo: int

var pick_up_ready: bool = false

func _process(delta):
	pass

func _ready():
	pass

func despawn():
	var collision = get_child(0)
	collision.disabled = true
	self.queue_free()
