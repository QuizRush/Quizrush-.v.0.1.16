extends Node2D

@onready var cameraMan = $Player/Camera2D
@onready var pause_menu = $PauseMenu
var enemy_scene = preload("res://Entities/Enemies/enemy.tscn")
@onready var character := $Player

var game_paused = false
var enemy_numbers = 6
func _ready():
	camera_set()
	for i in range(enemy_numbers):
		var orc = enemy_scene.instantiate()
		orc.position = Vector2(i*300, character.position.y)
		add_child(orc)


func _process(delta):
	pass

func camera_set():
	cameraMan.limit_right = 1150
	cameraMan.limit_left = 3
	cameraMan.limit_top = 1
	cameraMan.limit_bottom = 655
	
func _unhandled_input(event):
	if event.is_action_pressed("esc"):
		game_paused = !game_paused 
		if game_paused :
			Engine.time_scale = 0
			pause_menu.visible = true
		else:
			Engine.time_scale = 1
			pause_menu.visible = false
		get_tree().root.get_viewport().set_input_as_handled()	
