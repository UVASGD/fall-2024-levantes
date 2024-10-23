extends CharacterBody3D

var player

func _ready():
	$Timer.start(0.5)
	await $Timer.timeout
	player = PlayerManager.player

