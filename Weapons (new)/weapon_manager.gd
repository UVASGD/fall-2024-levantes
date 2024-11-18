extends Node3D
var Shop_Weapon = "res://shop_weapon.gd"
var throwable = "res://throwable.gd"
var ammo = "res://ammo_drop.gd"
var Powerup = "res://powerup.gd"
var current_weapon = null
var other_weapon = null
var can_pickup = false
@onready var hud = $"../HUD"
var can_switch = false
var can_spawn = true
var nearby_weapon = null
var pickup_detection
var animationplayer

var is_input_lock_on = false
var is_meleeing = false
var is_reloading = false
var grenade_equipped = false
var grenade = null
var grenade_count = 0
var money = 0
var shop_ray = null
var curr_shop_ray_name = ""
var in_buy_phase = true
# Called when the node enters the scene tree for the first time.
func _ready():
	var weapon_array = []
	if get_child_count() > 1:
		current_weapon = get_child(1)
		weapon_array.append(current_weapon)
		if get_child_count() > 2:
			other_weapon = get_child(2)
			weapon_array.append(other_weapon)
		hud.hud_initialize(weapon_array)
		await hide_weapon(other_weapon)
		await show_weapon(current_weapon)
	if other_weapon:
		can_switch = true
	SignalBus.connect("update_ammo", call_update_ammo)
	SignalBus.connect("call_hud_initialize", call_hud_initialize)
	SignalBus.connect("wave_killed", reward_money)
	SignalBus.connect("wave_killed", turn_on_in_buy_phase)
	pickup_detection = %pickup_detection
	pickup_detection.body_entered.connect(_on_pickup_detection_body_entered)
	pickup_detection.body_exited.connect(_on_pickup_detection_body_exited)
	shop_ray = $"../RayCast3D"
	call_money_update(money, "")
	pass
	
	 


var has_printed_weapon_name = false  

func _process(delta):
	if not curr_shop_ray_name and shop_ray and shop_ray.is_colliding():
		var collider = shop_ray.get_collider()
		
		# Ensure the collider and its parent exist, and check if it's a Shop_Weapon or Powerup
		if collider and collider.get_parent() and (collider.get_parent() is Shop_Weapon or collider.get_parent() is Powerup):
			var item = collider.get_parent()
			curr_shop_ray_name = item.item_name
			var price = item.price
			
			if not has_printed_weapon_name:
				call_update_shop_weapon_name(curr_shop_ray_name, price)
				has_printed_weapon_name = true
	elif curr_shop_ray_name and (not shop_ray or not shop_ray.is_colliding()):
		# Reset when ray is no longer colliding
		curr_shop_ray_name = ""
		call_update_shop_weapon_name(curr_shop_ray_name, 0)
		has_printed_weapon_name = false


func _input(event):
	if event.is_action_pressed("debug_button"):
		hide_weapon(current_weapon)
	if event.is_action_pressed("Weapon_Switch"):
		if can_switch and not is_input_lock_on:
			is_input_lock_on = true
			await switch()
			is_input_lock_on = false
			call_hud_initialize()
	if can_pickup and Input.is_action_just_pressed("pick_up_weapon"):
		await pickup()
		call_hud_initialize()
		
	if event.is_action_pressed("Shoot"):
		if grenade_equipped:
				throw()
				return
		if current_weapon == null:
			return
		current_weapon.shoot()
	if event.is_action_pressed("buy"):
		if shop_ray and shop_ray.is_colliding() and in_buy_phase:
			#print("buy")
			buy()
			return
	if event.is_action_pressed("Reload"):
		if current_weapon == null or grenade_equipped or current_weapon.Curr_Mag_Ammo == current_weapon.Max_Mag_Capacity or current_weapon.Reserve_Ammo == 0:
			return
		can_switch = false
		await current_weapon.reload()
		can_switch = true
		call_hud_initialize()
	if event.is_action_pressed("Melee"):
		if current_weapon == null or grenade_equipped:
			return
		can_switch = false
		await current_weapon.call_melee_animation()
		can_switch = true
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
		current_weapon.Reserve_Ammo += new_weapon.Reserve_Ammo
		nearby_weapon.despawn()
		return
	if other_weapon != null and new_weapon.Name == other_weapon.Name:
		other_weapon.Reserve_Ammo += new_weapon.Reserve_Ammo
		nearby_weapon.despawn()
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

func turn_on_in_buy_phase():
	in_buy_phase = true

func buy():
	if(shop_ray.get_collider().get_parent() is Shop_Weapon):
		SignalBus.emit_signal("gun_purchase", shop_ray.get_collider().get_parent())
		var player_position = $"../../..".global_transform.origin
		#print("buying")
		var shop_weapon = shop_ray.get_collider().get_parent()
		money -= shop_weapon.price
		
		if money < 0:
			go_in_debt()
		else:
			call_money_update(money, "")
		var new_weapon = shop_weapon.sell()
		get_tree().root.get_child(3).add_child(new_weapon) # hardcoded 3 because bishoptestworld  is the third child of root. May change later
		new_weapon.position = player_position + Vector3(0, 3, 3)
	elif(shop_ray.get_collider().get_parent() is Powerup):
		SignalBus.emit_signal("gun_purchase", shop_ray.get_collider().get_parent())
		shop_ray.get_collider().get_parent().apply()
	else:
		in_buy_phase = false
		SignalBus.emit_signal("round_start")
		
	return

func go_in_debt():
	#print("you are in debt")
	var num = randi_range(0,1)
	if num == 0:
		call_money_update(money, "half health and shield")
		PlayerManager.player.max_health_hp = PlayerManager.player.max_health_hp / 2
		PlayerManager.player.health_hp = PlayerManager.player.health_hp / 2
	elif num == 1:
		PlayerManager.player.health_regen_timer.wait_time = PlayerManager.player.health_regen_timer.wait_time / 2
		PlayerManager.player.shield_regen_timer.wait_time = PlayerManager.player.shield_regen_timer.wait_time / 2
		call_money_update(money, "slower regen")
	return

func _on_pickup_detection_body_entered(body):
	nearby_weapon = body
	if nearby_weapon is ammo:
		if current_weapon and nearby_weapon.type == current_weapon.name:
			current_weapon.Reserve_Ammo += nearby_weapon.amount 
			nearby_weapon.despawn()
		elif other_weapon and nearby_weapon.type == other_weapon.name:
			other_weapon.Reserve_Ammo += nearby_weapon.amount 
			nearby_weapon.despawn()
		return
	else:
		can_pickup = true
		#print(nearby_weapon)

func _on_pickup_detection_body_exited(body):
	nearby_weapon = null
	can_pickup= false

func call_hud_initialize():
	var weapon_array = [current_weapon, other_weapon]
	hud.hud_initialize(weapon_array)

func call_update_ammo(ammo):
	hud.update_ammo(ammo)

func call_update_shop_weapon_name(s_wep_name, price):
	hud.update_shop_weapon_name(s_wep_name, price)

func call_money_update(money, debt_effect):
	hud.update_money(money, debt_effect)

func reward_money():
	money += 1
	call_money_update(money, "")
