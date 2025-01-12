extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$AnimationPlayer.play("new_animation")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_texture_button_button_up() -> void:
	fade_to_black()
	await $fade.animation_finished
	get_tree().change_scene_to_file("res://credits.tscn")
	pass # Replace with function body.


func _on_playbutton_button_up() -> void:
	fade_to_black()
	await $fade.animation_finished
	if PersistentData.is_first_game():
		get_tree().change_scene_to_file("res://summary.tscn")
		# opening scene
	else:
		#random scene
		await GameManager.next("nothing", self)
		return
func transition():
	await recurse_free(self)
	get_tree().change_scene_to_file(get_nextWorld())
	Loader.change_level(get_nextWorld())
	pass



func recurse_free(node):
	for child in node.get_children():
		recurse_free(child)
	if node == self:
		return
	node.queue_free()
	return
func get_nextWorld():
	var list = GameManager.worlds.keys()
	var randkey = list[randi() % list.size()]
	return GameManager.worlds[randkey]

func fade_to_black():
	$fade.play("fade")
