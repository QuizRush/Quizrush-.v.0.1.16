extends Node2D
var orc_scene := preload("res://Entities/Enemies/orc_enemy_1/enemy.tscn")
var spawner_points := []

func _ready():
	for i in get_children():
		if i is Marker2D:
			spawner_points.append(i)

func _process(delta):
	pass


func _on_timer_timeout():
	var spawn = spawner_points[randi() % spawner_points.size()]
	var orc = orc_scene.instantiate()
	orc.position = spawn.position
	add_child(orc)
	
