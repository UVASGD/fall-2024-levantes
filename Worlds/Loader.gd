extends Node

var loading_screen = load("res://Worlds/loadingscreen.tscn")
var scene_path: String

func change_level(path):
	scene_path = path
	get_tree().change_scene_to_packed(loading_screen)
