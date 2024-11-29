#class_name AlienPistol extends "res://Weapons (new)/functional/gun.gd"
extends Gun
var is_charging = false
var charge_time = 0.0
var max_charge_time = 1.0
var crit_time = 0.75
var can_fire = false
var local_can_shoot = true
var is_firing = false
var charge_timer: Timer
var shoot_lock_on = false

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


func _physics_process(delta: float) -> void:
	
	#if can_fire:
		#if Input.is_action_just_pressed("Shoot"):
			#start_charging()
		#elif Input.is_action_just_released("Shoot"):
			#release_shot()
		#if is_charging:
			#charge_time += delta
			#charge_time = min(charge_time, max_charge_time)
		#pass
	
	if !can_fire:
		return
	if Curr_Mag_Ammo > 0:
		if Input.is_action_just_pressed("special_shoot"):
			#start_charge_timer()
			if !is_firing:
				start_charging()
		elif Input.is_action_just_released("special_shoot"):
			if is_charging:
				release_shot()
			elif charge_timer and charge_timer.is_stopped():
				animation_player.play("alien_pistol/overheat")
				await animation_player.animation_finished
	if is_charging:
		charge_time += delta
		charge_time = min(charge_time, max_charge_time)
		


	
func start_charging():
	if is_firing:
		return
	is_charging = true
	is_firing = false
	charge_time = 0.0
	animation_player.play("alien_pistol/charge")
	
	#print("Charging started")


func release_shot():
	#print("charge released")
	#print(charge_time)
	if !is_charging:
		return
		
	is_charging = false
	animation_player.stop()

	if charge_time >= crit_time and charge_time < 1.0:
		Curr_Mag_Ammo = 0
		SignalBus.emit_signal("update_ammo", Curr_Mag_Ammo)
		await crit_shot()
	Curr_Mag_Ammo = 0
	SignalBus.emit_signal("update_ammo", Curr_Mag_Ammo)
	await reload()
	#else:
		#shoot()
	charge_time = 0.0
	is_firing = false

func shoot():
	if is_charging:
		return
	if is_firing:
		return
	is_firing = true
	
	can_shoot = false
	#await get_tree().create_timer(Shoot_Cooldown_Ms).timeout
	var Curr_Ammo_Loop = Curr_Mag_Ammo #loop safe variable
	for i in min(Burst_Count, Curr_Ammo_Loop):
		SignalBus.emit_signal("weapon_fire_recoil", recoil_amount, snap_amount, recoil_speed)
		await play_fire()
		Curr_Mag_Ammo -= 1
		SignalBus.emit_signal("update_ammo", Curr_Mag_Ammo)
	if Curr_Mag_Ammo == 0:
		if Reserve_Ammo > 0:
			await reload()
			
		else:
			can_shoot = false
			return

	await get_tree().create_timer(Wait_Interval).timeout
	#Is_Waiting = false
	can_shoot = true
	is_firing = false
	pass
func crit_shot():
	if is_firing:
		return
	is_firing = true
	#print("crit")
	#await shoot()
	$Overheat.play()
	SignalBus.emit_signal("weapon_fire_recoil", recoil_amount, snap_amount, recoil_speed)
	animation_player.play("alien_pistol/overheat")
	await animation_player.animation_finished
	#return

func create_projectile():
	var projectile = load("res://projectiles/alien_pistol_projectile_overhaul.tscn").instantiate()
	%projectile_spawn.add_child(projectile)
	projectile.throw()

func create_shockwave():
	#print("make shock")
	var shock = load("res://projectiles/nice_shockwave.tscn").instantiate()
	get_node("../../../../").add_child(shock)
	return
	
func equip():
	can_fire = true
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

func dequip():
	can_fire = false
	is_charging = false
	is_firing = false
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
	
