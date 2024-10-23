extends CharacterBody3D

@onready var detection_radius = $detection
var curr_state = "idle"
var next_state = "idle"


func _ready():
	pass

func _physics_process(delta):
	match curr_state:
		"idle":
			idle()
		"attack":
			attack(delta)

func idle():
	pass

func attack(delta):
	print("attacked")


func _on_detection_body_entered(body):
	if body.is_in_group("Player"):
		next_state = "attack"
