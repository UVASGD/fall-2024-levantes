extends Node
var worlds = {
	"dummyworld1":"res://Worlds/dummyworld1.tscn",
	"dummyworld2":"res://Worlds/dummyworld2.tscn",
	"space_world":"res://Worlds/space_world.tscn",
	"colliseum":"res://arena1_final.tscn"
}
var current_difficulty = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func next(current):
	get_tree().change_scene_to_file(nextWorld(current))
	
func nextWorld(current):
	var list = worlds.keys()
	list.erase(current)
	if list.size() == 0:
		return null
	var randkey = list[randi() % list.size()]
	return worlds[randkey]
