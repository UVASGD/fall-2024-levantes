'''
	Make sure to remove print statements when not debugging.
	
	Print statements reduce performance a lot
'''

#TODO: Remove debug button bs

extends Node3D


@onready var Animation_Player = get_node("WeaponRig/AnimationPlayer")

signal hit(target)

var Current_Weapon = null

var o_wep = null

var Weapon_Stack = [] #Should be 2 weapons at most
var Weapon_Indicator: int = 0

var Other_Weapon: String

var Weapon_List = {}

var raycast_test = preload("res://Scenes/Assets/raycast_test.tscn")

var in_pickup_range = false

var sp_weapon

var hud

@export var _weapon_resources: Array[Weapon_Resource]

@export var Starting_Weapons: Array[String]

enum {NULL,HITSCAN,PROJECTILE}

func _ready():
	Initialize(Starting_Weapons) #Enter the state machine

'''
	Don't handle checks in this function
'''
func _input(event):
	
	if event.is_action_pressed("debug_button"):
		hide_wep(Current_Weapon.Wep_Name)
		
	if event.is_action_pressed("Weapon_Switch"):
		var cur_anim = Animation_Player.get_current_animation()
		if cur_anim != Current_Weapon.Dequip_Ani and Weapon_Stack.size() > 1:
			Weapon_Indicator = !Weapon_Indicator
			exit(Weapon_Stack[Weapon_Indicator], false)
	#if event.is_action_pressed("Drop_Weapon"):
		#spawn_drop_weapon(Current_Weapon.Wep_Name)
	if in_pickup_range and Input.is_action_just_pressed("pick_up_weapon"):
		if o_wep == null:
			var weapon_in_stack = Weapon_Stack.find(sp_weapon.weapon_name, 0)
			if weapon_in_stack == -1:
				Weapon_Indicator = !Weapon_Indicator
				Weapon_Stack.insert(Weapon_Indicator,sp_weapon.weapon_name)
				Weapon_List[sp_weapon.weapon_name].Curr_Mag_Ammo = sp_weapon.current_ammo
				Weapon_List[sp_weapon.weapon_name].Reserve_Ammo = sp_weapon.reserve_ammo
				
				emit_signal("Update_Weapon_Stack", Weapon_Stack)
				exit(sp_weapon.weapon_name, true)
				sp_weapon.queue_free()
			print(sp_weapon.weapon_name)
		else:
			var weapon_in_stack = Weapon_Stack.find(sp_weapon.weapon_name, 0)
			if weapon_in_stack == -1:
				spawn_drop_weapon(Current_Weapon.Wep_Name)
				Weapon_Stack.remove_at(Weapon_Stack.find(Current_Weapon.Wep_Name, 0))
				hide_wep(Current_Weapon.Wep_Name)
				#Weapon_Indicator = !Weapon_Indicator
				Weapon_Stack.insert(Weapon_Indicator,sp_weapon.weapon_name)
				
				Weapon_List[sp_weapon.weapon_name].Curr_Mag_Ammo = sp_weapon.current_ammo
				Weapon_List[sp_weapon.weapon_name].Reserve_Ammo = sp_weapon.reserve_ammo
				
				emit_signal("Update_Weapon_Stack", Weapon_Stack)
				exit(sp_weapon.weapon_name, true)
				sp_weapon.queue_free()
				Current_Weapon = Weapon_List[Weapon_Stack[Weapon_Indicator]]
				enter()
				print(Current_Weapon.Wep_Name)
				
		
			#print(sp_weapon.weapon_name)
			
		

func Initialize(_Starting_Weaps: Array):
	var wep_objs = []
	for weapon in _weapon_resources:
		Weapon_List[weapon.Wep_Name] = weapon
	
	for s_weps in _Starting_Weaps:
		Weapon_Stack.push_back(s_weps)
		
	
	hud = $"../HUD"
	

	hud.hud_initialize(Weapon_Stack, Weapon_List)
	
	
	Current_Weapon = Weapon_List[Weapon_Stack[0]]
	
	for wep in Weapon_List.values():
		if wep.Wep_Name != Current_Weapon.Wep_Name:
			hide_wep(wep.Wep_Name)
	if Weapon_Stack.size() > 1 and Weapon_List[Weapon_Stack[1]]:
			o_wep = Weapon_List[Weapon_Stack[1]]
			hide_wep(o_wep.Wep_Name)
		
	enter()
func call_update_pickup():
	hud.hud_initialize(Weapon_Stack, Weapon_List)
	hud.update_weapon_indicator(Weapon_Indicator)
	
func enter():
	Animation_Player.queue(Current_Weapon.Equip_Ani)
	
func exit(_next_weapon: String, is_pickup: bool):
	if Weapon_Stack.size() > 1 and _next_weapon != Current_Weapon.Wep_Name:
		if Animation_Player.get_current_animation() != Current_Weapon.Dequip_Ani:
			Animation_Player.play(Current_Weapon.Dequip_Ani)
			Other_Weapon = _next_weapon
			if !is_pickup:
				await Animation_Player.animation_finished
				hud.update_weapon_indicator(Weapon_Indicator)
			else:
				#pass
				call_update_pickup()
			
			

'''
	There are no checks for if there's only one weapon in the stack
	The checks are handled in exits function
'''
func hide_wep(weapon_name: String):
	var weapon_node = get_node("WeaponRig/" + weapon_name)
	if weapon_node:
		weapon_node.hide()
func switch_Wep(weapon_name: String):
	#if Weapon_Stack.size() > 1:
	Current_Weapon = Weapon_List[weapon_name]
	Other_Weapon = ""
	enter()
		
func fire_Wep():
	var f_mode = Current_Weapon.Fire_Mode
	match f_mode:
		"single" :
			var cur_anim = Animation_Player.get_current_animation()
			var anim_check = (
					(cur_anim != Current_Weapon.Dequip_Ani) and 
					(cur_anim != Current_Weapon.Equip_Ani) and
					(cur_anim != Current_Weapon.Fire_Ani)
				)
			if Current_Weapon.Curr_Mag_Ammo != 0 and anim_check:
				_raycast()
				Animation_Player.play(Current_Weapon.Fire_Ani)
				$AudioStreamPlayer.play()
				Current_Weapon.Curr_Mag_Ammo -= 1
				hud.update_ammo(Current_Weapon.Curr_Mag_Ammo, Current_Weapon.Reserve_Ammo, Weapon_Indicator)
			elif Current_Weapon.Reserve_Ammo != 0 and anim_check:
				reload()
			# print("singlefire")
		"burst":
			var is_wait = Current_Weapon.Is_Waiting
			var is_rel = Current_Weapon.Is_Reloading
			var cur_mag_ammo = Current_Weapon.Curr_Mag_Ammo
			var burst_amount = Current_Weapon.Burst_Count
			
			var cur_anim = Animation_Player.get_current_animation()
			var ammo_checks = cur_mag_ammo != 0 and cur_mag_ammo >= burst_amount
			
			if ammo_checks:
				var checks = (cur_anim != Current_Weapon.Dequip_Ani and cur_anim != Current_Weapon.Equip_Ani and cur_anim != Current_Weapon.Reload_Ani and !is_wait and !is_rel)
				if !checks:
					pass
				elif checks:
					for i in range(burst_amount):
						if Current_Weapon.Is_Reloading:
							Current_Weapon.Is_Reloading = false
						#elif i == 2:
							#await Animation_Player.animation_finished
						Animation_Player.play(Current_Weapon.Fire_Ani)
						$AudioStreamPlayer.play()
						if %Ray.is_colliding():
							emit_signal("hit", %Ray.get_collider())
							print(%Ray.get_collider())
						_raycast()
						#print(str(Current_Weapon.Curr_Mag_Ammo) + "\n")
						Current_Weapon.Curr_Mag_Ammo -= 1
						await Animation_Player.animation_finished
						hud.update_ammo(Current_Weapon.Curr_Mag_Ammo, Current_Weapon.Reserve_Ammo, Weapon_Indicator)
						#if i == burst_amount-1:
							#await Animation_Player.animation_finished
					Current_Weapon.Is_Waiting = true
					Animation_Player.play(Current_Weapon.Wait_Ani)
					#await Animation_Player.animation_finished
					await get_tree().create_timer(Current_Weapon.Wait_Interval).timeout
					Current_Weapon.Is_Waiting = false
			elif cur_mag_ammo != 0:
				for i in range(0, cur_mag_ammo):
					if i != 0:
						await Animation_Player.animation_finished
					Animation_Player.play(Current_Weapon.Fire_Ani)
					Current_Weapon.Curr_Mag_Ammo -= 1
					hud.update_ammo(Current_Weapon.Curr_Mag_Ammo, Current_Weapon.Reserve_Ammo, Weapon_Indicator)
			elif Current_Weapon.Reserve_Ammo != 0 and Current_Weapon.Curr_Mag_Ammo == 0:
				reload()
		"auto":
			if Current_Weapon.Curr_Mag_Ammo != 0:
				var cur_anim = Animation_Player.get_current_animation()
				var anim_checks = (cur_anim != Current_Weapon.Dequip_Ani and cur_anim != Current_Weapon.Equip_Ani)
				if anim_checks and Current_Weapon.Curr_Mag_Ammo != 0:
					while Input.is_action_pressed("Shoot") and Current_Weapon.Curr_Mag_Ammo != 0 and Animation_Player.get_current_animation() != Current_Weapon.Reload_Ani:
						Animation_Player.play(Current_Weapon.Fire_Ani)
						$AudioStreamPlayer.play()
						#if %Ray.is_colliding():
							##emit_signal("hit", %Ray.get_collider())
							##print(%Ray.get_collider())
							#pass
						_raycast()
						Current_Weapon.Curr_Mag_Ammo -= 1
						await Animation_Player.animation_finished
						hud.update_ammo(Current_Weapon.Curr_Mag_Ammo, Current_Weapon.Reserve_Ammo, Weapon_Indicator)
						if Current_Weapon.Reserve_Ammo != 0 and Current_Weapon.Curr_Mag_Ammo == 0:
							reload()
				elif anim_checks and Current_Weapon.Curr_Mag_Ammo == 0 and Current_Weapon.Reserve_Ammo != 0:
					reload()


	
func reload():
	var r_ammo = Current_Weapon.Reserve_Ammo
	var c_mag_ammo = Current_Weapon.Curr_Mag_Ammo
	var max_mag_ammo = Current_Weapon.Max_Mag_Capacity
	
	var refill_amount = max_mag_ammo - c_mag_ammo
	if c_mag_ammo == max_mag_ammo:
		pass
	elif r_ammo >= refill_amount:
		var cur_anim = Animation_Player.get_current_animation()
		if ((cur_anim != Current_Weapon.Dequip_Ani) 
			and (cur_anim != Current_Weapon.Equip_Ani)
			and cur_anim != Current_Weapon.Reload_Ani
		):
			Animation_Player.play(Current_Weapon.Reload_Ani)
			Current_Weapon.Curr_Mag_Ammo += refill_amount
			Current_Weapon.Reserve_Ammo -= refill_amount
			await Animation_Player.animation_finished
			hud.update_ammo(Current_Weapon.Curr_Mag_Ammo, Current_Weapon.Reserve_Ammo, Weapon_Indicator)
	else:
		var cur_anim = Animation_Player.get_current_animation()
		if ((cur_anim != Current_Weapon.Dequip_Ani) 
			and (cur_anim != Current_Weapon.Equip_Ani)
			and cur_anim != Current_Weapon.Reload_Ani
		):
			Animation_Player.play(Current_Weapon.Reload_Ani)
			Current_Weapon.Curr_Mag_Ammo += refill_amount
			Current_Weapon.Reserve_Ammo = 0
			await Animation_Player.animation_finished
			hud.update_ammo(Current_Weapon.Curr_Mag_Ammo, Current_Weapon.Reserve_Ammo, Weapon_Indicator)

func _on_animation_player_animation_finished(anim_name):
	if anim_name == Current_Weapon.Dequip_Ani:
		switch_Wep(Other_Weapon)

func _raycast() -> void:
	var camera = %Camera3D
	var space_state = camera.get_world_3d().direct_space_state
	
	var screen_center = get_viewport().size / 2
	var origin = camera.project_ray_origin(screen_center)
	#var endpoint = origin + camera.project_ray_normal(screen_center) * Current_Weapon.Projectile_Range
	var endpoint = origin + camera.project_ray_normal(screen_center) * Current_Weapon.Projectile_Range
	var query = PhysicsRayQueryParameters3D.create(origin, endpoint)
	var intersection = get_world_3d().direct_space_state.intersect_ray(query)
	query.collide_with_bodies = true
	query.collide_with_areas = false
	var result = space_state.intersect_ray(query)
	if result:
		#print(screen_center)
		make_spark(result.get("position"), origin-endpoint)
		
		
		
	if not intersection.is_empty():
		#emit_signal("hit", intersection.get("collider"))
		SignalBus.emit_signal("enemy_hit", Current_Weapon.dmg, intersection.get("collider"))
		#print(intersection.get("collider"))
	else:
		print("nothing")
		
		
		
		
func make_spark(impact_position: Vector3, raycast_angle: Vector3) -> void:
	emit_signal("hit", %Ray.get_collider())
	print(%Ray.get_collider())
	var instance = Raycast_test.new()
	instance.directionval = raycast_angle
	instance.impactpoint = impact_position
	get_tree().root.add_child(instance)
	instance.global_position = impact_position
	await get_tree().create_timer(1).timeout
	instance.queue_free()
	
func spawn_drop_weapon(w_name: String):
	var wep_ref = Weapon_Stack.find(w_name, 0)
	#if wep_ref != -1 and Weapon_Stack.size() > 0:
	if wep_ref != -1:
		#Weapon_Stack.pop_at(wep_ref)
		emit_signal("Update_Weapon_Stack", Weapon_Stack)
		
		var Weapon_Dropped = Weapon_List[w_name].Weapon_Drop.instantiate()
		Weapon_Dropped.current_ammo = Weapon_List[w_name].Curr_Mag_Ammo
		Weapon_Dropped.reserve_ammo = Weapon_List[w_name].Reserve_Ammo
		
		Weapon_Dropped.set_global_transform($WeaponRig/tracer_spawn_point.get_global_transform())
		var World = get_tree().get_root().get_child(0)
		World.add_child(Weapon_Dropped)
		
		#Current_Weapon = Weapon_List[Weapon_Stack[0]]
		#enter()

		
		
#func update_hud():
	#


func _on_pickup_detection_body_entered(body):
	sp_weapon = body
	in_pickup_range = true
	print(sp_weapon)


func _on_pickup_detection_body_exited(body):
	sp_weapon = null
	in_pickup_range = false
