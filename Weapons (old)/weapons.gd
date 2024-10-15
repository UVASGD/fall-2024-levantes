class_name Weapons extends Node3D

#
##The different fire types
#enum FireType{
	#SINGLE,
	#BURST,
	#AUTO
#}
#@export var gun_name : String
#@export var ammo_reserve : int
#@export var mag_size : int
#@export var fire_rate : float
#@export var burst_amount : int = 3
#@export var damage : int
#@export var current_fire_type: FireType = FireType.AUTO
#@export var reload_length: float
#
#var curr_ammo_in_mag: int
#var is_shooting : bool = false
#var is_reloading: bool = false
#var last_fire_time : float = 0.0
#
#func _ready():
	#curr_reserve_ammo = ammo_reserve
	#curr_ammo_in_mag = mag_size
	#if current_fire_type == null:
		#current_fire_type = FireType.AUTO
		#
#func single_fire():
	#if curr_ammo_in_mag == 0 and ammo_reserve != 0:
		#reload()
	#match current_fire_type:
		#FireType.SINGLE:
			#
			#
		#
#func single_fire():
	#if curr_ammo_in_mag != 0:
		#var time_now = OS.get_ticks_msc() / 1000.0
		#if time_now - last_fire_time >= fire_rate:
			#last_fire_time = time_now
			#curr_ammo_in_mag -= 1
			#
			#
		#
#func burst_fire():
	#
#func auto_fire():
	#
#func reload():
	#if is_reloading:
		#return
	#if ammo_reserve > 0 and curr_ammo_in_mag < mag_size:
		#is_shooting = false
		#is_reloading = true		
		##add code to play reload animation when ready
		#
		##This line pauses things for the reload animation
		#await get_tree().create_timer(reload_length).timeout
		#
		#var ammo_to_add = mag_size - curr_ammo_in_mag
		#if curr_reserve_ammo >= ammo_to_add:
			#curr_reserve_ammo -= ammo_to_add
			#curr_ammo_in_mag = mag_size
		#else:
			#curr_ammo_in_mag += curr_reserve_ammo
			#curr_reserve_ammo = 0
		#is_reloading = false
		#
		#
#func shoot_effect_spawn():
	##TODO: Implement the bullets going, hitscan, etc.
		#
	#
#
#
#
