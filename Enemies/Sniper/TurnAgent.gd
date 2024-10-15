extends Node3D


@onready var face_target_y = $y_axis
@onready var face_target_x = $y_axis/x_axis
var target : Node3D
func _ready():
	target = get_tree().get_nodes_in_group("Player")[0]

func _process(delta):
	var target_pos = target.global_transform.origin
	face_target_y.face_point(target_pos, delta)
	face_target_x.face_point(target_pos, delta)

	if face_target_y.is_facing_target(target_pos) and face_target_x.is_facing_target(target_pos):
		show_angry()
	else:
		show_mellow()
func show_angry():
	$y_axis/x_axis/Angry_Face.show()
	$y_axis/x_axis/Mellow_Face.hide()

func show_mellow():
	$y_axis/x_axis/Angry_Face.hide()
	$y_axis/x_axis/Mellow_Face.show()
