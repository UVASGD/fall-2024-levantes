extends Node3D

var player
var score = 0

func _ready():
	SignalBus.connect("wave_killed", score_add)
func get_player():
	return player

func set_player(newplayer):
	player = newplayer
	return
	
func score_add():
	score += 1
	SignalBus.emit_signal("score_add")

func clear_status_effects():
	if player:
		player.health_hp = 100
		player.shield_hp = 100
		player.max_health_hp = 100
		player.max_shield_hp = 100
		player.walk_speed = 9.0
		player.shield_regen_timer.wait_time = 3.0
		player.health_regen_timer.wait_time = 6.0
