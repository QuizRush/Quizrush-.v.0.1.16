extends Control

func _ready():
	pass # Replace with function body.

func _process(delta):
	pass

func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")

func _on_host_pressed():
	get_tree().change_scene_to_file("res://Scenes/Authentication.tscn")
