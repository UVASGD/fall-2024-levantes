class_name world extends Node3D

@onready var player = $CharacterBody3D

#essentially just a counter
@onready var current_level = 0
#the level is the key the amount of monsters is the value

@onready var level_dict={ # key = level number. Value  = (num_waves, enemies_per_wave)
	1:[1,3],
	2:[2,5],
	3:[3,3],
	4:[3,5],
	5:[4,5],
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
func _ready():
	add_to_group("level")
	SignalBus.connect("enemy_death", enemy_death)
	SignalBus.connect("round_start", on_round_start)
	open_shop()

func open_shop():
	print("opening shop")
	var shop_instance = shop.instantiate()
	shop_spawn_point.add_child.call_deferred(shop_instance)
	
	
func on_shop_close():
	#start round
	#play battle music
	pass
	
func enemy_death():
	#print("enemy death")
	dead_enemies += 1 
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
		#we use that number to randomly select a spawner number
		var spawn_position = $SpawnHolder.get_child(rand_num)
		#we add the monster as a child of the level
		#we set the monsters position to the spawn location
		m.position = spawn_position.global_transform.origin
		add_child(m)
	#for i in range(level_dict.size()):
		#var m
		#var rand_monster_type_num = randi_range(1,5)
		#match rand_monster_type_num:
			#1:
				#m = monster.instantiate()
			#2:
				#m = sniper.instantiate() 
			#3:
				#m = bomb_enemy.instantiate()
			#4:
				#m = assassin.instantiate()
			#5:
				#m = hammer.instantiate()
		#m.set_next_state = "chase"
		##print("spawning enemy")
		##we check the amount of children on our spawn holder
		#var spawn_length = $SpawnHolder.get_child_count()-1
		#var rand_num = rand.randi_range(0,spawn_length)
		##we use that number to randomly select a spawner number
		#var spawn_position = $SpawnHolder.get_child(rand_num)
		##we add the monster as a child of the level
		##we set the monsters position to the spawn location
		#m.position = spawn_position.global_transform.origin
		#add_child(m)
		#
		#await get_tree().create_timer(2.0).timeout


func update_level(level):
	match level:
		1:
			print("it's level one")
		2:
			print("it's level two")
		3:
			print("it's level three")
		4:
			print("it's level four")
		5:
			print("it's level five")
	spawn_enemies()

func _on_in_between_waves_timeout():
	print("Leaving level: ", current_level)
	current_level +=1
	update_level(current_level)

func _physics_process(delta):
	get_tree().call_group("enemies", "update_target_location", player.global_transform.origin)

func on_round_start():
	current_level += 1
	spawn_enemies()

func on_wave_killed():
	dead_waves += 1
	if(dead_waves >= level_dict[current_level][0]): #round ended
		dead_waves = 0
		#play chill music
		open_shop()
	else:
		spawn_enemies()
	pass
