extends Control

var scene_path: String
var progress: Array
var loading_value

func _ready():
	scene_path = Loader.scene_path
	ResourceLoader.load_threaded_request(scene_path)
	
func _process(delta):
	ResourceLoader.load_threaded_get_status(scene_path, progress)
	loading_value = progress[0]
	
	if loading_value >= 1.0:
		get_tree().change_scene_to_packed(
			ResourceLoader.load_threaded_get(scene_path)
		)
	
