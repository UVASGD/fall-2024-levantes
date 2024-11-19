extends Node3D
@onready var area = $Area3D
@onready var animation_player = $AnimationPlayer
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	area.connect("body_entered", _on_body_entered)
	area.connect("body_exited", _on_body_exited)
	animation_player.connect("animation_finished", play_animation)
	play_animation()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.jump_velocity = 27.0

func _on_body_exited(body):
	if body.is_in_group("Player"):
		body.jump_velocity = 9.0

func play_animation():
	$AnimationPlayer.play("idle")
