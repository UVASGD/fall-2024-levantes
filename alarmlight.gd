extends SpotLight3D
var increasing = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	light_energy = 0
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if increasing:
		light_energy += 0.1
	else:
		light_energy -= 0.1
	if light_energy >= 14:
		increasing = false
	elif light_energy <=0:
		increasing = true
	pass
