extends Node3D
@onready var smg = preload("res://Weapons (new)/shop/shop_smg.tscn")
@onready var burst = preload("res://Weapons (new)/shop/shop_burst.tscn")
@onready var sniper = preload("res://Weapons (new)/shop/shop_sniper.tscn")
@onready var deagle = preload("res://Weapons (new)/shop/shop_deagle.tscn")
@onready var gl = preload("res://Weapons (new)/shop/shop_grenade_launcher.tscn")
@onready var vl = preload("res://Weapons (new)/shop/shop_void_launcher.tscn")
@onready var ap = preload("res://Weapons (new)/shop/shop_alien_pistol.tscn")
var active_guns = []
# Called when the node enters the scene tree for the first time.
func _ready():
	print("hello i am a shop")
	SignalBus.connect("round_start", on_round_start)
	SignalBus.connect("gun_purchase", on_gun_purchase)
	add_guns()
	$AnimationPlayer.play("open")
	pass # Replace with function body.

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func add_guns():
	#var gun_list = [smg,burst,sniper,deagle,gl, vl, ap]
	var gun_list = [ap]
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
		gun.queue_free()
	queue_free()
