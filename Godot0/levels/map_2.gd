extends Node2D

# Declare variables
var enemy_scene = preload("res://Entities/Enemies/orc_enemy_1/enemy.tscn")
var spawnpoints : Array  # Declare as Array
@export var playerScene : PackedScene
@export var enemy_numbers : int = 6  # Declare with export
var game_paused : bool = false  # Declare with export if needed

func _ready():
	spawnpoints = get_tree().get_nodes_in_group("SpawnPoint")  # Fetch spawn points
	var keys = NakamaMultiplayer.Players.keys()  # Assuming NakamaMultiplayer is properly initialized
	keys.sort()
	
	# Check for enough spawn points
	if keys.size() > spawnpoints.size():
		print("Warning: Not enough spawn points for all players.")
		return
	
	# Instantiate players
	for index in range(keys.size()):
		var player_key = keys[index]
		var instancedPlayer = playerScene.instantiate()
		instancedPlayer.name = str(NakamaMultiplayer.Players[player_key].name)
		add_child(instancedPlayer)  # Add player to the scene
		
		# Set camera limits
		var camera = instancedPlayer.get_node("Camera2D")
		camera.limit_right = 1150
		camera.limit_left = 3
		camera.limit_top = 1
		camera.limit_bottom = 655
		
		instancedPlayer.global_position = spawnpoints[index].global_position
		
		# Spawn enemies relative to the player
		for j in range(enemy_numbers):
			var orc = enemy_scene.instantiate()
			orc.position = Vector2(j * 300 + instancedPlayer.position.x, instancedPlayer.position.y)
			add_child(orc)  # Add orc to the scene

func _process(delta):
	pass  # You can implement game logic here
