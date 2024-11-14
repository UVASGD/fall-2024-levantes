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
