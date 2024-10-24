extends Node3D

var throwable = "res://throwable.gd"
var current_weapon = null
var other_weapon = null
var can_pickup = false
var hud
var can_switch = false
var can_spawn = true
var nearby_weapon = null
var pickup_detection
var animationplayer

var grenade_equipped = false
var grenade = null
var grenade_count = 0
# Called when the node enters the scene tree for the first time.
func _ready():

	if get_child_count() > 1:
		current_weapon = get_child(1)
		if get_child_count() > 2:
			other_weapon = get_child(2)
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
		if grenade_equipped:
				throw()
				return
		if current_weapon == null:
			return
		current_weapon.shoot()
	if event.is_action_pressed("Reload"):
		if current_weapon == null or grenade_equipped:
			return
		await current_weapon.reload()
	if event.is_action_pressed("grenade"):
		equip_throwable()
	pass

func equip_throwable():
	if grenade != null:
		await hide_weapon(current_weapon)
		await grenade.equip()
		grenade_equipped = true

func dequip_throwable():
	if grenade:
		await grenade.dequip()
		grenade_equipped = false

func throw():
	if grenade:
		await grenade.throw()
		grenade = null
		grenade_equipped = false
	if current_weapon:
		await current_weapon.equip()

func pickup_throwable(weapon):
	if current_weapon != null:
		await current_weapon.dequip()
	grenade = weapon
	add_child(grenade)
	await grenade.equip()
	grenade_equipped = true

		
func pickup():
	var new_weapon 
	if nearby_weapon == null:
		return
	
	new_weapon = nearby_weapon.get_weapon()
	if new_weapon is throwable:
		if grenade != null and grenade.name == new_weapon.name:
			return
		nearby_weapon.despawn()
		await pickup_throwable(new_weapon)
		return
	if current_weapon != null and new_weapon.Name == current_weapon.Name:
		return
	if other_weapon != null and new_weapon.Name == other_weapon.Name:
		return
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
	if(grenade_equipped):
		can_switch = false
		await dequip_throwable()
		await show_weapon(current_weapon)
		can_switch = true
		return
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


