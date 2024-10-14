extends Node3D

var current_weapon = null
var other_weapon = null
var can_pickup = false
var hud
var can_switch = false
var can_spawn = true
var nearby_weapon = null
var pickup_detection
var animationplayer
# Called when the node enters the scene tree for the first time.
func _ready():
	if get_child_count() > 0:
		current_weapon = get_child(0)
		if get_child_count() > 1:
			other_weapon = get_child(1)
		await hide_weapon(other_weapon)
		await show_weapon(current_weapon)
	if other_weapon:
		can_switch = true

	pickup_detection = %pickup_detection
	pickup_detection.body_entered.connect(_on_pickup_detection_body_entered)
	pickup_detection.body_exited.connect(_on_pickup_detection_body_exited)
	pass 

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event.is_action_pressed("debug_button"):
		hide_weapon(current_weapon)
	if event.is_action_pressed("Weapon_Switch"):
		if can_switch:
			await switch()
	if can_pickup and Input.is_action_just_pressed("pick_up_weapon"):
		await pickup()
	if event.is_action_pressed("Shoot"):
		if current_weapon == null:
			return
		current_weapon.shoot()
	if event.is_action_pressed("Reload"):
		if current_weapon == null:
			return
		await current_weapon.reload()
	pass

func pickup():
	var new_weapon 
	if nearby_weapon == null:
		return
	else:
		new_weapon = nearby_weapon.get_weapon()
	var nearby_weapon_save = nearby_weapon #creating a new husk will cause a signal to be sent and  the nearbyweapon to be updated. This variable keeps the current one so that it does not free the one it creates in this function
	var nearby_weapon_save_curr_ammo = nearby_weapon.current_ammo
	var nearby_weapon_save_reserve_ammo = nearby_weapon.reserve_ammo
	if other_weapon == null:	#holding less than 2 weapons
		nearby_weapon_save.despawn()
		add_child(new_weapon)
		new_weapon.hide()
		if current_weapon == null: # if player has no guns
			await new_weapon.equip()
			current_weapon = new_weapon
		else:
			other_weapon = new_weapon
			can_switch = true
	elif can_spawn: #already holding 2 weapons
		can_spawn = false
		await current_weapon.dequip()
		await drop_weapon()
		current_weapon = new_weapon
		nearby_weapon_save.despawn()
		add_child(new_weapon)
		new_weapon.hide()
		await new_weapon.equip()
		can_spawn = true

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
		await show_weapon(other_weapon)
		var temp = other_weapon
		other_weapon = current_weapon
		current_weapon = temp
		can_switch = true

func drop_weapon():
	var husk = current_weapon.get_husk()
	var player_position = $"../../..".global_transform.origin
	
	get_tree().root.add_child(husk)
	husk.position = player_position + Vector3(0,1,0)
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


