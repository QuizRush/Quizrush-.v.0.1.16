extends Control

func _ready():
	pass # Replace with function body.

func _process(delta):
	pass

func _on_p_pressed():
	get_tree().change_scene_to_file("res://Scenes/Menu/NavBar.tscn")

func _on_2p_pressed():
	get_tree().change_scene_to_file("res://Scenes/2p.tscn")

func _on_exit_pressed():
	get_tree().quit()


func _on_options_pressed():
	get_tree().change_scene_to_file("res://Scenes/options.tscn")
