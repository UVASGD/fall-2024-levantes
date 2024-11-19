extends Node3D
signal glass_broken
var me
@onready var has_broken = false
# Called when the node enters the scene tree for the first time.
func _ready():
	me = $StaticBody3D
	SignalBus.connect("object_hit", _on_hit)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	pass

func _on_hit(target):
	if (target == me) and not has_broken:
		has_broken = true
		emit_signal("glass_broken")
		$AudioStreamPlayer.play()
		$OmniLight3D3.light_energy = 0
		

