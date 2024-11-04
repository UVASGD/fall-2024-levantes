
extends RayCast3D

var is_laser_on = false
@export var max_length = -10000000
@export var min_length = -0.1
@onready var beam = $beam_mesh
var length
# Called when the node enters the scene tree for the first time.
func _ready():
	is_laser_on = false
	change_beam_length(0)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if is_laser_on != null and is_laser_on:
		var contact_point
		
		force_raycast_update()
		
		if is_colliding():
			var collider = get_collider()
			if collider.is_in_group("laser"):
				add_exception(collider)
			contact_point = to_local(get_collision_point())
			length = contact_point.y
			if collider.is_in_group("Player"):
				SignalBus.emit_signal("sniper_can_see_player")
				length += -5
			change_beam_length(length)
	else:
		change_beam_length(0)
		#else:
			#change_beam_length(max_length)
func change_beam_length(length):
	beam.mesh.height = length
	beam.position.y = length/2
	
func activate():
	is_laser_on = true
	visible = true
	
func deactivate():
	is_laser_on = false
	visible = false
