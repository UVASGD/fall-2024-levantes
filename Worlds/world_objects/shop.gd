extends Node3D
@onready var smg = preload("res://Weapons (new)/shop/shop_smg.tscn")
@onready var burst = preload("res://Weapons (new)/shop/shop_burst.tscn")
@onready var sniper = preload("res://Weapons (new)/shop/shop_sniper.tscn")
@onready var deagle = preload("res://Weapons (new)/shop/shop_deagle.tscn")
@onready var gl = preload("res://Weapons (new)/shop/shop_grenade_launcher.tscn")
@onready var vl = preload("res://Weapons (new)/shop/shop_void_launcher.tscn")
@onready var ap = preload("res://Weapons (new)/shop/shop_alien_pistol.tscn")
@onready var bh = preload("res://Weapons (new)/shop/bonus_health.tscn")
@onready var fr = preload("res://Weapons (new)/shop/fast_regen.tscn")
@onready var sb = preload("res://Weapons (new)/shop/speed_boost.tscn")
var active_guns = []
# Called when the node enters the scene tree for the first time.
func _ready():
	print("hello i am a shop")
	SignalBus.connect("round_start", on_round_start)
	SignalBus.connect("gun_purchase", on_gun_purchase)
	SignalBus.connect("player_death", despawn)
	add_guns()
	$AnimationPlayer.play("open")
	pass # Replace with function body.

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func add_guns():
	var gun_list = [smg, burst, sniper, deagle, gl, vl, ap, bh, fr, sb]
	for holder in $shop_model/gun_holders.get_children():
		var gun = gun_list[randi_range(0,gun_list.size()-1)].instantiate()
		gun.top_level = true
		get_tree().root.add_child(gun)
		active_guns.append(gun)
		#holder.add_child(gun)
		
		var remote = RemoteTransform3D.new()
		remote.update_scale = false
		holder.add_child(remote)
		remote.global_transform.origin += Vector3(0,0.6,0)
		remote.remote_path = remote.get_path_to(gun)
		

	pass

func on_round_start():
	$AnimationPlayer.play("close")

func on_gun_purchase(gun):
	active_guns.remove_at(active_guns.find(gun))

func despawn():
	for gun in active_guns:
		if gun:
			gun.queue_free()
	queue_free()
