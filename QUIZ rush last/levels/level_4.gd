extends Node2D

var spawnpoints 
@export var playerScene : PackedScene

func _ready():
	spawnpoints = get_tree().get_nodes_in_group("SpawnPoint")
	var index = 0
	var keys = NakamaMultiplayer.Players.keys()
	keys.sort()
	for i in keys:
		var instancedPlayer = playerScene.instantiate()
		instancedPlayer.name = str(NakamaMultiplayer.Players[i].name)
		add_child(instancedPlayer)
		instancedPlayer.global_position = spawnpoints[index].global_position
		index += 1
	pass 

func _process(delta):
	pass


func _on_area_2d_body_entered(body):
	if body.has_method("take_damage"):
		body.queue_free()

