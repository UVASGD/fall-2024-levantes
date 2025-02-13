class_name Gun extends Node3D

@export var husk_weapon_path: String
@export var model_path: String
@export var Name: String
@export var Display_Name: String
@export var animation_player_treepath: String
@export var animation_library_path: String
@export var volume_db_increase: int = 0
@export var change_pitch_mult: float = 1.0
@export var max_pol: int = 3
@export var Reset_Ani: String
@export var Equip_Ani: String
@export var Fire_Ani: String
@export var Reload_Ani: String
@export var Dequip_Ani: String
@export var Wait_Ani: String
@export var Melee_Ani: String

@export var can_headshot: bool = false


@export var Fire_Sound: String
@export var Reward_Amount: int
@export var Curr_Mag_Ammo: int
@export var Reserve_Ammo: int
@export var Max_Mag_Capacity: int
@export var Max_Ammo: int
@export var Shoot_Cooldown_Ms: int
@export var Fire_Mode: String
@export var Burst_Count: int
@export var Wait_Interval: float
@export var Is_Waiting: bool
@export var is_reloading: bool
@export_flags("HitScan","Projectile") var Type
@export var Projectile_Range: float
@export var Melee_Range: float = 4

@export var dmg: int
@export var headshot_multiplier: float = 1.0
@export var melee_dmg: int

@export var Weapon_Drop: PackedScene

@export var ray_path: String
@export var light_path: String


signal hit(target)
var can_equip
var can_dequip
var can_shoot
var can_reload
var animation_player
var model
var audio_player
var last_shot_time = 0



# Called when the node enters the scene tree for the first time.
func _ready():
	var model = get_child(0)
	animation_player = get_node(animation_player_treepath)
	#print(animation_player)
	audio_player = AudioStreamPlayer.new()
	audio_player.max_polyphony = max_pol
	audio_player.pitch_scale = change_pitch_mult
	audio_player.volume_db = volume_db_increase
	audio_player.stream = load(Fire_Sound)
	add_child(audio_player)
	var root = get_tree().root
	can_equip = true
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
	
func shoot(): #default shoot logic
	while Input.is_action_pressed("Shoot") and can_shoot:
		#await get_tree().create_timer(Shoot_Cooldown_Ms).timeout
		await play_fire()
		_raycast(dmg, headshot_multiplier, Projectile_Range)
		Curr_Mag_Ammo -= 1
		SignalBus.emit_signal("update_ammo", Curr_Mag_Ammo)
	#hud.update_ammo(Curr_Mag_Ammo, Reserve_Ammo, Weapon_Indicator)
		if Curr_Mag_Ammo == 0:
			if Reserve_Ammo > 0:
				await reload()
				SignalBus.emit_signal("call_hud_initialize")
			else:
				can_shoot = false #out of all ammo
	pass

func pass_curr_mag_ammo():
	return Curr_Mag_Ammo

func reload():
	if Curr_Mag_Ammo == Max_Mag_Capacity || !can_reload:
		return
		
	can_dequip = false
	can_shoot = false
	can_reload = false
	
	var refill_amount = Max_Mag_Capacity - Curr_Mag_Ammo
	
	if Reserve_Ammo <= refill_amount:
		refill_amount = Reserve_Ammo
		Reserve_Ammo = 0
	else:
		Reserve_Ammo -= refill_amount
		
	animation_player.play(Reload_Ani)
	Curr_Mag_Ammo += refill_amount
	await animation_player.animation_finished
	SignalBus.emit_signal("call_hud_initialize")
	#hud.update_ammo(Curr_Mag_Ammo, Reserve_Ammo, Weapon_Indicator)
	can_reload = true
	can_shoot = true
	can_dequip = true
	
	pass

func dequip():
	if !can_dequip:
		return
	can_equip = false
	can_shoot = false
	can_reload = false
	can_dequip = false
	#print("playing $Name dequip")
	animation_player.play(Dequip_Ani)
	await animation_player.animation_finished
	#print("finished $Name dequip")
	hide()
	
	can_equip = true
	return
	
func equip():
	if !can_equip:
		return
	can_shoot = false
	can_reload = false
	can_dequip = false
	can_equip = false
	
	show()
	#print("playing $Name equip")
	animation_player.play(Equip_Ani)
	await animation_player.animation_finished
	#print("finished $Name equip")
	if(Curr_Mag_Ammo > 0):
		can_shoot = true
	can_reload = true
	can_dequip = true

func melee():
	pass
	
func make_bullet_trail(target_pos: Vector3):
	pass

func call_melee_animation():
	animation_player.play(Reset_Ani)
	await animation_player.animation_finished
	animation_player.queue(Melee_Ani)

func _raycast(dmg, hs_mult, range):
	var camera = get_parent().get_parent()
	var space_state = camera.get_world_3d().direct_space_state
	var screen_center = get_viewport().size / 2
	var origin = camera.project_ray_origin(screen_center)
	var endpoint = origin + camera.project_ray_normal(screen_center) * range
	var query = PhysicsRayQueryParameters3D.create(origin, endpoint)
	var intersection = get_world_3d().direct_space_state.intersect_ray(query)
	query.collide_with_bodies = true
	query.collide_with_areas = false
	if not intersection.is_empty():
		
		#SignalBus.emit_signal("enemy_hit", dmg, headshot_multiplier, intersection.get("collider"))
		
		var collider = intersection.get("collider")
		if collider is CharacterBody3D and collider.is_in_group("enemies"):
			SignalBus.emit_signal("enemy_hit", dmg, headshot_multiplier, collider, intersection.get("shape"))

		#print(intersection.get("collider"))
		
	else:
		pass
		#print("nothing")
		
func get_husk():
	var husk = load(husk_weapon_path)
	var  new_husk = husk.instantiate()
	new_husk.current_ammo = Curr_Mag_Ammo
	new_husk.reserve_ammo = Reserve_Ammo
	new_husk.name = Name
	return new_husk
	
func get_reward_amount():
	return Reward_Amount
	
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

func play_fire():
	animation_player.play(Fire_Ani)
	audio_player.play()
	await animation_player.animation_finished

func add_animationplayer(ani):
	animation_player = ani
