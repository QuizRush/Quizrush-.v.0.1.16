extends Node2D
@export var multiplayerScene1 : PackedScene
@export var multiplayerScene2 : PackedScene
@export var multiplayerScene3 : PackedScene


# Called when the node enters the scene tree for the first time.
func _ready():
	$UI.OnStartGame.connect(onStartGame)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func onStartGame():
	if(MultiplayerNakamaManager.level_custom_data["selected_map"] == "Negen ger"):
		$MultiplayerScene.add_child(multiplayerScene1.instantiate())
	if(MultiplayerNakamaManager.level_custom_data["selected_map"] == "Baigaliin saihand hunii saihantai"):
		$MultiplayerScene.add_child(multiplayerScene2.instantiate())
	if(MultiplayerNakamaManager.level_custom_data["selected_map"] == "Mist forest"):
		$MultiplayerScene.add_child(multiplayerScene3.instantiate())
		
		
	
