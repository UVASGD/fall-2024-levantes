class_name throwable extends RigidBody3D


@export var force:int
@export var upDirection:float
@export var damage:int
@export var cooldown:float
@export var equip_ani:String
@export var dequip_ani:String
var timer
var collision
var animation_player

# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	gravity_scale = 0
	sleeping = true
	animation_player = get_child(3)
	collision = get_child(1)
	collision.disabled = true
	body_entered.connect(_on_body_entered)
	timer = Timer.new()
	timer.wait_time = cooldown
	add_child(timer)
	timer.connect("timeout", action)
	
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func throw():
	show()
	gravity_scale = 1
	print("throwing")
	var playerRotation = get_parent().global_transform.basis.z.normalized()
	reparent(get_tree().root)
	apply_central_impulse(playerRotation * force + Vector3(0, upDirection, 0))
	print("collision delaying")
	await get_tree().create_timer(0.2).timeout
	print("collision ready")
	collision.disabled = false
	return

	
func equip():
	print("playing eqiup")
	animation_player.play(equip_ani)
	await animation_player.animation_finished
	print("equip finished")
	return

func dequip():
	print("playing dequip")
	animation_player.play(dequip_ani)
	await animation_player.animation_finished
	print("dequip finished")
	hide()
	return

func _on_body_entered(body):
	print("hit")
	if timer.is_stopped(): # timer starts on first collision, does not start again on bounce
		timer.start()
	linear_damp = 0.3
	angular_damp = 1.5

func action():
	print("this is the throwable parent action. Implement it in your child script!")
