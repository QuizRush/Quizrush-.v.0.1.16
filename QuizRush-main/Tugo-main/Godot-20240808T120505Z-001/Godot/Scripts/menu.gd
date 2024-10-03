extends Control

func _on_exit_pressed():
	get_tree().quit()


func _on_options_pressed():
	get_tree().change_scene_to_file("res://Scenes/options.tscn")


func _on_level_customize_pressed():
	get_tree().change_scene_to_file("res://Scenes/level_customize.tscn")


func _on_play_pressed():
	get_tree().change_scene_to_file("res://Scenes/zavsariin.tscn")
