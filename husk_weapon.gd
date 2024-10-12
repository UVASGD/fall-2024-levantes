class_name husk_weapon
extends RigidBody3D


@export var weapon_name: String
@export var current_ammo: int
@export var reserve_ammo: int

@export var collision_layers = [4]
@export var mask_layers = [1,3,4]

var pick_up_ready: bool = false

func _process(delta):
	pass

func _ready():
	initialize_collision_and_mask()

func initialize_collision_and_mask():
	for col_layer in collision_layers:
		$".".set_collision_layer_value(col_layer, true)
	for m_layer in mask_layers:
		$".".set_collision_mask_value(m_layer, true)

func despawn():
	var collision = get_child(0)
	collision.disabled = true
	self.queue_free()
