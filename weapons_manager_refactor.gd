extends Node3D

const smg = preload("res://smg_refactor.tscn")
const burst_refactor = preload("res://burst-refactor.tscn")
const husk_smg = preload("res://husk_smg.tscn")
const sp_burst_rifle = preload("res://Models/Weapons/spawnable_weapons/sp_burst_rifle.tscn")

var current_weapon = null
var other_weapon = null
var can_pickup = false
var hud
var can_switch = false
var nearby_weapon = null
# Called when the node enters the scene tree for the first time.
func _ready():
	current_weapon = get_child(0)
	other_weapon = get_child(1) #change this to support not spawning in with 2 weapons 
	await hide_weapon(other_weapon)
	await show_weapon(current_weapon)
	if other_weapon:
		can_switch = true
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event.is_action_pressed("debug_button"):
		hide_weapon(current_weapon)
	if event.is_action_pressed("Weapon_Switch"):
		if can_switch:
			switch()
	if can_pickup and Input.is_action_just_pressed("pick_up_weapon"):
		pickup()
	if event.is_action_pressed("Shoot"):
		current_weapon.shoot()
		#print("Weapon: " + Current_Weapon.Wep_Name + "\n" + "Weapon_Indicator: " + str(Weapon_Indicator))
	if event.is_action_pressed("Reload"):
		current_weapon.reload()
	pass

func pickup():
	var nearby_weapon_save = nearby_weapon #creating a new husk will cause a signal to be sent and  the nearbyweapon to be updated. This variable keeps the current one so that it does not free the one it creates in this function
	if other_weapon == null:
			match nearby_weapon.weapon_name:
				"smg":
					var smg = smg.instantiate()
					remove_child(nearby_weapon_save)
					add_child(smg)
					other_weapon = smg
					other_weapon.Curr_Mag_Ammo = nearby_weapon.current_ammo
					other_weapon.Reserve_Ammo = nearby_weapon.reserve_ammo
				#insert cases for other gun types
	else:
		match nearby_weapon.weapon_name:
			"smg":
				var smg = smg.instantiate()
				smg.hide()
				drop_weapon()
				current_weapon = smg
				nearby_weapon_save.despawn()
				add_child(smg)
				await smg.equip()
			"burst":
				var burst = burst_refactor.instantiate()
				burst.hide()
				await drop_weapon()
				current_weapon = burst
				nearby_weapon_save.despawn()
				
				add_child(burst)
				await burst.equip()
		#insert cases for other gun types
		current_weapon.Curr_Mag_Ammo = nearby_weapon.current_ammo
		current_weapon.Reserve_Ammo = nearby_weapon.reserve_ammo
		


func hide_weapon(weapon):
	if weapon:
		if weapon == current_weapon:
			await weapon.dequip()
		else:
			weapon.hide()

func show_weapon(weapon):
	if weapon:
		weapon.equip()

func switch():
	if(other_weapon != null):
		can_switch = false
		await hide_weapon(current_weapon)
		show_weapon(other_weapon)
		var temp = other_weapon
		other_weapon = current_weapon
		current_weapon = temp
		can_switch = true


	
func drop_weapon():
	var husk = current_weapon.get_husk()
	await current_weapon.dequip()
	get_tree().root.add_child(husk)
	current_weapon.queue_free()
	current_weapon = null
	pass
	
func _on_pickup_detection_body_entered(body):
	nearby_weapon = body
	can_pickup = true
	print(nearby_weapon)


func _on_pickup_detection_body_exited(body):
	nearby_weapon = null
	can_pickup= false

