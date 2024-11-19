class_name husk_weapon
extends RigidBody3D


@export var weapon_name: String
@export var current_ammo: int
@export var reserve_ammo: int

@export var collision_layers = [4]
@export var mask_layers = [1,3,4]
@export var real_weapon_path = ""

var pick_up_ready: bool = false

func _process(delta):
	pass

func _ready():
	SignalBus.connect("player_death", despawn)
	initialize_collision_and_mask()

func initialize_collision_and_mask():
	$".".set_collision_layer_value(1, false)
	$".".set_collision_mask_value(1, false)
	for col_layer in collision_layers:
		$".".set_collision_layer_value(col_layer, true)
	for m_layer in mask_layers:
		$".".set_collision_mask_value(m_layer, true)

func despawn():
	var collision = get_child(0)
	collision.disabled = true
	self.queue_free()

func get_weapon():
	var new_gun = load(real_weapon_path)
	var new_gun_scene = new_gun.instantiate()
	new_gun_scene.Curr_Mag_Ammo = current_ammo
	new_gun_scene.Reserve_Ammo = reserve_ammo
	return new_gun_scene
