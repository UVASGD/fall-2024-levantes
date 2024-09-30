class_name husk_weapon
extends RigidBody3D


@export var weapon_name: String
@export var current_ammo: int
@export var reserve_ammo: int
signal collided
var pick_up_ready: bool = false

func _process(delta):
	var bodies = get_colliding_bodies()
	if bodies:
		emit_signal("collided")

func _ready():
	contact_monitor=true
