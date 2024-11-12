class_name world extends Node3D

@onready var difficulty = 1
var player
@export var world_name: String
#essentially just a counter
@onready var current_level = 0
#the level is the key the amount of monsters is the value

@onready var level_dict={ # key = level number. Value  = (num_waves, enemies_per_wave)
	1:[1,10],
	2:[2,10],
	#3:[3,3],
	#4:[3,5],
	#5:[4,5],
}
@onready var shop = preload("res://Worlds/world_objects/shop.tscn")
#the monster we will be spawing in
@onready var monster = preload("res://Enemies/state_machine_test/smt_new/smt_update.tscn")
@onready var sniper = preload("res://Enemies/bishop_sniper/bishop_sniper.tscn")
@onready var bomb_enemy = preload("res://Enemies/wallbreaker/wallbreaker.tscn")
@onready var assassin = preload("res://Enemies/assassin/assassin.tscn")
@onready var hammer = preload("res://Enemies/hammerguy/hammerguy.tscn")
#A random number generator to spawn from alternating spawn points
@onready var rand = RandomNumberGenerator.new()
@onready var dead_enemies = 0
@onready var dead_waves = 0
@onready var shop_spawn_point = $shopspawnpoint
var player_ready = false
func _ready():
	difficulty = SignalBus.current_difficulty
	add_to_group("level")
	SignalBus.connect("enemy_death", enemy_death)
	SignalBus.connect("round_start", on_round_start)
	apply_difficulty()
	if not $playerspawnpoint:
		print("please add a player spawnpoint")
	spawn_player()
	open_shop()
	if not $Nav:
		print("please set up a navmesh and make all world objects children of it ")
	add_static_collisions($Nav)
	if not shop_spawn_point:
		print("please set up a shop spawn point")
	if not $SpawnHolder:
		print("please set up a spawnholder")
	
func spawn_player():
	print("making player")
	var newplayer
	if not PlayerManager.get_player():
		newplayer = load("res://player/shop_player.tscn").instantiate()
	else:
		newplayer = PlayerManager.get_player()
	newplayer.add_to_group("Player", true)
	$playerspawnpoint.add_child(newplayer)
	player = newplayer
	player_ready = true
	return
	
func add_static_collisions(node): # recursively adds collisions to every mesh3d in  the scene, unless the nodes have children 
	for child in node.get_children():
		print('hi')
		if child is MeshInstance3D:
			if child.get_child_count() > 0:
				continue
			print(child)
			var static_body = StaticBody3D.new()
			var collision_shape = CollisionShape3D.new()
			var shape = child.mesh.create_trimesh_shape()
			collision_shape.shape = shape
			static_body.add_child(collision_shape)
			static_body.transform = child.transform
			node.add_child(static_body)
		elif child is Node3D:
			add_static_collisions(child)

func apply_difficulty():
	for val in level_dict:
		level_dict[val][1] = level_dict[val][1] * difficulty
	return
	
func open_shop():
	print("opening shop")
	var shop_instance = shop.instantiate()
	shop_spawn_point.add_child.call_deferred(shop_instance)
	

func enemy_death():
	dead_enemies += 1
	print("enemies left: " + str(level_dict[current_level][1] - dead_enemies)) 
	if dead_enemies >= level_dict[current_level][1]:
		dead_enemies = 0
		on_wave_killed()
#
func spawn_enemies(): #spawns 1 wave of enemies
	for i in range(level_dict[current_level][1]):
		var m
		var rand_monster_type_num = randi_range(1,5)
		match rand_monster_type_num:
			1:
				m = monster.instantiate()
			2:
				m = sniper.instantiate() 
			3:
				m = bomb_enemy.instantiate()
			4:
				m = assassin.instantiate()
			5:
				m = hammer.instantiate()
		m.set_next_state = "chase"
		var spawn_length = $SpawnHolder.get_child_count()-1
		var rand_num = rand.randi_range(0,spawn_length)
		var spawn_position = $SpawnHolder.get_child(rand_num)
		m.position = spawn_position.global_transform.origin
		add_child(m)


func _physics_process(delta):
	if player_ready:
		get_tree().call_group("enemies", "update_target_location", player.global_transform.origin)

func on_round_start():
	current_level += 1
	print("level" + str(current_level))
	spawn_enemies()
	#play battle music

func on_wave_killed():
	print("wave over.")
	dead_waves += 1
	print("waves left: " + str(level_dict[current_level][0] - dead_waves))
	if(dead_waves >= level_dict[current_level][0]): #round ended
		dead_waves = 0
		#play chill music
		if(current_level == level_dict.size()): # all levels complete
			change_world()
			return
		open_shop()
	else:
		spawn_enemies()
	pass

func rand_music():
	return

func change_world():
	SignalBus.current_difficulty += 1
	PlayerManager.set_player(player)
	player.get_parent().remove_child(player)
	print("changin world")
	GameManager.next(world_name)
	pass
