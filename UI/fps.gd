extends ColorRect

func _process(delta):
	$fps_counter.text = str(Engine.get_frames_per_second())
