extends Node3D

const smg = preload("res://smg.gd")
var weapons = [null, null]
var current_weapon = null
var other_weapon = null
var can_pickup = false
var hud
var can_switch = false
var nearby_weapon = null
# Called when the node enters the scene tree for the first time.
func _ready():
	for i in 2:
		if get_child(i):
			weapons[i] = get_child(i)
	current_weapon = weapons[0]
	other_weapon = weapons[1]
	hide_weapon(other_weapon)
	show_weapon(current_weapon)
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

func pickup():
	if other_weapon == null:
			match nearby_weapon.weapon_name:
				"SMG":
					var smg = smg.new()
					add_child(smg)
					weapons[1] = smg
					other_weapon = smg
					other_weapon.Curr_Mag_Ammo = nearby_weapon.current_ammo
					other_weapon.Reserve_Ammo = nearby_weapon.reserve_ammo
					nearby_weapon.queue_free()
				#insert cases for other gun types
	else:
		match nearby_weapon.weapon_name:
			"SMG":
				var smg = smg.new()
				smg.hide()
				weapons[0] = smg
				current_weapon = smg
				other_weapon.Curr_Mag_Ammo = nearby_weapon.current_ammo
				other_weapon.Reserve_Ammo = nearby_weapon.reserve_ammo
				nearby_weapon.queue_free()
			#insert cases for other gun types

func hide_weapon(weapon):
	if weapon:
		if weapon == current_weapon:
			await weapon.dequip()
		else:
			weapon.hidden = true
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

func _raycast() -> void:
	var camera = %Camera3D
	var space_state = camera.get_world_3d().direct_space_state
	
	var screen_center = get_viewport().size / 2
	var origin = camera.project_ray_origin(screen_center)
	#var endpoint = origin + camera.project_ray_normal(screen_center) * Current_Weapon.Projectile_Range
	var endpoint = origin + camera.project_ray_normal(screen_center) * current_weapon.Projectile_Range
	var query = PhysicsRayQueryParameters3D.create(origin, endpoint)
	var intersection = get_world_3d().direct_space_state.intersect_ray(query)
	query.collide_with_bodies = true
	query.collide_with_areas = false
	#var result = space_state.intersect_ray(query)
	#if result:
		##print(screen_center)
		#make_spark(result.get("position"), origin-endpoint)
	if not intersection.is_empty():
		emit_signal("hit", intersection.get("collider"))
		print(intersection.get("collider"))
		
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
	#if wep_ref != -1:
		#Weapon_Stack.pop_at(wep_ref)
		#emit_signal("Update_Weapon_Stack", Weapon_Stack)
		#
		#var Weapon_Dropped = Weapon_List[w_name].Weapon_Drop.instantiate()
		#Weapon_Dropped.current_ammo = Weapon_List[w_name].Curr_Mag_Ammo
		#Weapon_Dropped.reserve_ammo = Weapon_List[w_name].Reserve_Ammo
		#
		#Weapon_Dropped.set_global_transform($WeaponRig/tracer_spawn_point.get_global_transform())
		#var World = get_tree().get_root().get_child(0)
		#World.add_child(Weapon_Dropped)
	pass
	
func _on_pickup_detection_body_entered(body):
	nearby_weapon = body
	can_pickup = true
	print(nearby_weapon)


func _on_pickup_detection_body_exited(body):
	nearby_weapon = null
	can_pickup= false


func _on_husk_weapon_collided(body):
	nearby_weapon = body
	can_pickup = true
	pass # Replace with function body.
