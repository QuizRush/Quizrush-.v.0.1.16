extends Node2D

@onready var cameraMan = $Player/Camera2D
@onready var pause_menu = $GUI
var enemy_scene = preload("res://Entities/Enemies/orc_enemy_1/enemy.tscn")
@onready var character := $Player
@onready var timer = $Timer
var game_paused = false
var enemy_numbers = 6
func _ready():
	
	camera_set()
	for i in range(enemy_numbers):
		var orc = enemy_scene.instantiate()
		orc.position = Vector2(i*300, character.position.y)
		add_child(orc)


func _process(delta):
	var remaining_time = timer.time_left
	
	$UI_manager/TextureProgressBar.value = remaining_time*20
	if($UI_manager/TextureProgressBar.value == 0):
		$UI_manager/Label2.visible = false
func camera_set():
	character.position = Vector2(2632, 490)
	cameraMan.limit_right = 3200
	cameraMan.limit_left = -45
	cameraMan.limit_top = -305
	cameraMan.limit_bottom = 605
	
#func _unhandled_input(event):
	#if event.is_action_pressed("pause"):
		#game_paused = !game_paused 
		#if game_paused :
			#Engine.time_scale = 0
			#pause_menu.visible = true
		#else:
			#Engine.time_scale = 1
			#pause_menu.visible = false
		#get_tree().root.get_viewport().set_input_as_handled()	
