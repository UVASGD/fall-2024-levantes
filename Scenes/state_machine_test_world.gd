extends Node3D

@onready var player = $CharacterBody3D

#essentially just a counter
@onready var current_level = 1
#the level is the key the amount of monsters is the value

@onready var wave_timer = $InBetweenWaves

@onready var monster_dict={
	1:1,
	2:2,
	3:3,
	4:4,
	5:5
}

#the monster we will be spawing in
@onready var monster = preload("res://Models/Enemies/state_machine_test/smt.tscn")
#A random number generator to spawn from alternating spawn points
@onready var rand = RandomNumberGenerator.new()
@onready var dead_enemies = 0

func _ready():
	add_to_group("level")
	SignalBus.connect("enemy_death", enemy_death)
	wave_timer.connect("timeout",_on_in_between_waves_timeout)

func enemy_death():
	print("enemy death")
	dead_enemies += 1 
	if dead_enemies == monster_dict[current_level]:
		wave_timer.start()
		dead_enemies = 0

func spawn_enemies():
	for i in range(monster_dict[current_level]):
		var m = monster.instantiate()
		print("spawning enemy")
		#we check the amount of children on our spawn holder
		var spawn_length = $SpawnHolder.get_child_count()-1
		var rand_num = rand.randi_range(0,spawn_length)
		#we use that number to randomly select a spawner number
		var spawn_position = $SpawnHolder.get_child(rand_num)
		#we add the monster as a child of the level
		#we set the monsters position to the spawn location
		m.position = spawn_position.global_transform.origin
		add_child(m)
		
		await get_tree().create_timer(2.0).timeout

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
