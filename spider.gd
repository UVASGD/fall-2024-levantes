extends CharacterBody3D

@onready var detection_radius = $detection
@onready var idle_mesh = $idle_mesh
@onready var attack_mesh = $attack_mesh
var curr_state = "idle"
var next_state = "idle"


func _ready():
	detection_radius.connect("body_entered", _on_detection_body_entered)
	detection_radius.connect("body_exited", _on_detection_body_exited)

func _physics_process(delta):
	curr_state = next_state
	match curr_state:
		"idle":
			idle()
		"attack":
			attack(delta)

func change_mesh(next_mesh):
	match next_mesh:
		idle_mesh:
			idle_mesh.show()
			attack_mesh.hide()
		attack_mesh:
			attack_mesh.show()
			idle_mesh.hide()
func idle():
	change_mesh(idle_mesh)


func attack(delta):
	change_mesh(attack_mesh)



func _on_detection_body_entered(body):
	if body.is_in_group("Player"):
		next_state = "attack"
		print("in attack radius")
		
func _on_detection_body_exited(body):
	if body.is_in_group("Player"):
		next_state = "idle"
		print("exited attack radius, in idle state now")
