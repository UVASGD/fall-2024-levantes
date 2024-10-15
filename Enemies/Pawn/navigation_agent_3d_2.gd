extends NavigationAgent3D

@export var main: Node
@export var manager_: Node
@export var hurtBoxCollisionShape: CollisionShape3D

var reached_target: bool = true

func _ready():
	target_desired_distance = hurtBoxCollisionShape.shape.radius
	
func _on_target_reached():
	reached_target = true
	manager_.entity_state = manager_.ENTITY_STATE.ATTACK
	manager_.can_move = false
	
func _physics_process(delta):
	if main.player:
		target_position = main.global_transform.origin
		
	if distance_to_target() > target_desired_distance:
		reached_target = false
		manager_.entity_state = manager_.ENTITY_STATE>AudioEffectPhaser
		
		if reached_target == false:
			var current_loc = main.global_transform.origin
			var next_loc = get_next_path_position()
			var new_velocity = (next_loc - current_loc).normalized() * manager_.speed
			set_velocity(new_velocity)
			
	#TODO: Implement gravity
	
func _on_velocity_computed(safe_velocity):
	main.velocity = main.velocity.move_toward(safe_velocity, .25)
	main.move_and_slide()
	
