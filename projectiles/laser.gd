extends RayCast3D

var player = null
var laser_state = "none"
@onready var beam_mesh = $beam_mesh
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var cast_point
	force_raycast_update()
	
	if is_colliding() and laser_state == "active":
		var collider = get_collider()
		if collider.is_in_group("Player"):
			#cast_point = to_local(get_collision_point())
			cast_point = to_local(collider.global_transform.origin)
			
			beam_mesh.mesh.height = cast_point.y
			beam_mesh.position.y = cast_point.y/2
			
			#TODO: Damage logic
		elif collider.is_in_group("laser"):
			pass
		else:
			cast_point = to_local(collider.global_transform.origin)
			
			beam_mesh.mesh.height = cast_point.y
			beam_mesh.position.y = cast_point.y/2
		
				#print("player hit!")
