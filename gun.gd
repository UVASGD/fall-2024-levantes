class_name Gun extends Node3D

@export var model_path: String
@export var Name: String
@export var Display_Name: String
@export var Equip_Ani: String
@export var Fire_Ani: String
@export var Reload_Ani: String
@export var Dequip_Ani: String
@export var Wait_Ani: String

@export var Fire_Sound: String

@export var Curr_Mag_Ammo: int
@export var Reserve_Ammo: int
@export var Max_Mag_Capacity: int
@export var Max_Ammo: int

@export var Fire_Mode: String
@export var Burst_Count: int
@export var Wait_Interval: float
@export var Is_Waiting: bool
@export var Is_Reloading: bool

@export_flags("HitScan","Projectile") var Type
@export var Projectile_Range: float
@export var dmg: int

@export var Weapon_Drop: PackedScene

@export var ray_path: String
@export var light_path: String

signal hit(target)

var animation_player
var model
var audio_player
var hidden = true
# Called when the node enters the scene tree for the first time.
func _ready():
	var model = get_child(0)
	audio_player = AudioStreamPlayer.new()
	audio_player.max_polyphony = 3
	audio_player.stream = load(Fire_Sound)
	add_child(audio_player)
	
	animation_player = %AnimationPlayer
	pass 


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _input(event):
	if(hidden):
		return
	if event.is_action_pressed("Shoot"):
		shoot()
		#print("Weapon: " + Current_Weapon.Wep_Name + "\n" + "Weapon_Indicator: " + str(Weapon_Indicator))
	if event.is_action_pressed("Reload"):
		reload()
	pass
	
func shoot():
	if Curr_Mag_Ammo != 0:
				var cur_anim = animation_player.get_current_animation()
				var anim_checks = (cur_anim != Dequip_Ani and cur_anim != Equip_Ani)
				if anim_checks and Curr_Mag_Ammo != 0:
					while Input.is_action_pressed("Shoot") and Curr_Mag_Ammo != 0 and animation_player.get_current_animation() != Reload_Ani:
						animation_player.play(Fire_Ani)
						audio_player.play()
						#if %Ray.is_colliding():
							##emit_signal("hit", %Ray.get_collider())
							##print(%Ray.get_collider())
							#pass
						_raycast()
						Curr_Mag_Ammo -= 1
						await animation_player.animation_finished
						#hud.update_ammo(Curr_Mag_Ammo, Reserve_Ammo, Weapon_Indicator)
						if Reserve_Ammo != 0 and Curr_Mag_Ammo == 0:
							reload()
				elif anim_checks and Curr_Mag_Ammo == 0 and Reserve_Ammo != 0:
					reload()
	pass

func reload():
	var r_ammo = Reserve_Ammo
	var c_mag_ammo = Curr_Mag_Ammo
	var max_mag_ammo = Max_Mag_Capacity
	
	var refill_amount = max_mag_ammo - c_mag_ammo
	if c_mag_ammo == max_mag_ammo:
		pass
	elif r_ammo >= refill_amount:
		var cur_anim = animation_player.get_current_animation()
		if ((cur_anim != Dequip_Ani) 
			and (cur_anim != Equip_Ani)
			and cur_anim != Reload_Ani
		):
			animation_player.play(Reload_Ani)
			Curr_Mag_Ammo += refill_amount
			Reserve_Ammo -= refill_amount
			await animation_player.animation_finished
			#hud.update_ammo(Curr_Mag_Ammo, Reserve_Ammo, Weapon_Indicator)
	else:
		var cur_anim = animation_player.get_current_animation()
		if ((cur_anim != Dequip_Ani) 
			and (cur_anim != Equip_Ani)
			and cur_anim != Reload_Ani
		):
			animation_player.play(Reload_Ani)
			Curr_Mag_Ammo += refill_amount
			Reserve_Ammo = 0
			await animation_player.animation_finished
			#hud.update_ammo(Curr_Mag_Ammo, Reserve_Ammo, Weapon_Indicator)
	pass

func dequip():
	animation_player.play(Dequip_Ani)
	hidden = true
	await animation_player.animation_finished
	hide()
	
func equip():
	show()
	animation_player.play(Equip_Ani)
	await animation_player.animation_finished
	hidden = false

func _raycast():
	var camera = get_parent().get_parent()
	var space_state = camera.get_world_3d().direct_space_state
	
	var screen_center = get_viewport().size / 2
	var origin = camera.project_ray_origin(screen_center)
	#var endpoint = origin + camera.project_ray_normal(screen_center) * Current_Weapon.Projectile_Range
	var endpoint = origin + camera.project_ray_normal(screen_center) * Projectile_Range
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
	#emit_signal("hit", %Ray.get_collider())
	#print(%Ray.get_collider())
	var instance = Raycast_test.new()
	instance.directionval = raycast_angle
	instance.impactpoint = impact_position
	get_tree().root.add_child(instance)
	instance.global_position = impact_position
	await get_tree().create_timer(1).timeout
	instance.queue_free()

