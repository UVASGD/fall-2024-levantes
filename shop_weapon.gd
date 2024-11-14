class_name Shop_Weapon extends Node3D

@export var price: int
@export var ammo:int
@export var reserve:int
@export var husk_weapon_path:String
var can_sell = true

# Called when the node enters the scene tree for the first time.
func _ready():
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$model.rotation_degrees = $model.rotation_degrees + Vector3(0,1,0)
	$StaticBody3D.rotation_degrees = $StaticBody3D.rotation_degrees + Vector3(0,1,0)
	pass

func sell():
	if can_sell:
		can_sell = false
		var new_gun = get_husk()
		self.queue_free()
		return new_gun


func get_husk():
	var new_gun = load(husk_weapon_path)
	var new_gun_scene = new_gun.instantiate()
	new_gun_scene.current_ammo = ammo
	new_gun_scene.reserve_ammo = reserve
	return new_gun_scene
