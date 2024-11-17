extends Node

var save_data = {"money":0, "high_score":0,}
var first_game = true
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	load_save_file()
	SignalBus.connect("score_add", _on_score_add)
	print("money: " + str(save_data["money"]))
	print("high score: " + str(save_data["high_score"]))
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func load_save_file() -> void:
	if FileAccess.file_exists("user://save.dat"):
		var file = FileAccess.open("user://save.dat", FileAccess.READ)
		var json = JSON.new()
		var error = json.parse(file.get_as_text())
		if error == OK:
			var data = json.data
			if typeof(data) == TYPE_DICTIONARY:
				save_data["money"] = data.get("money", 0)
				save_data["high_score"] = data.get("high_score", 0)
			first_game = false
		file.close()
	else:
		save_to_file()

func save_to_file() -> void:
	var file = FileAccess.open("user://save.dat", FileAccess.WRITE)
	file.store_string(JSON.stringify(save_data))

func _update_high_score():
	if PlayerManager.score > save_data["high_score"]:
		save_data["high_score"] = PlayerManager.score
		save_to_file()

func update_money(amount):
	if save_data["money"] + amount < 0: # too expensive 
		return -1
	save_data["money"] += amount
	save_to_file()
	return 1

func is_first_game():
	return first_game
	
func _on_score_add():
	_update_high_score()
	update_money(1)
