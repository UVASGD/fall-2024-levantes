extends Node
var worlds = {
	"space_world":"res://Worlds/space_world.tscn",
	"colliseum":"res://arena1_final.tscn",
	"observatory":"res://Models/optimized_observatory2/optimized_observatory2.tscn"
}
var important_nodes = [PlayerManager, SignalBus, self, PersistentData]
var current_difficulty = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func next(current, scene=null):
	await recurse_free(scene, scene)
	var next = nextWorld(current)
	#get_tree().change_scene_to_file(nextWorld(current))
	Loader.change_level(nextWorld(current))
	return

func recurse_free(node, scene=null):
	if not node:
		return
	for child in node.get_children():
		if child != PlayerManager.player:
			recurse_free(child)
	if node == scene:
		return
	node.queue_free()

func nextWorld(current):
	var list = worlds.keys()
	if current != "nothing":
		list.erase(current)
	if list.size() == 0:
		return null
	var randkey = list[randi() % list.size()]
	return worlds[randkey]
