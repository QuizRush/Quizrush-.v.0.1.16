extends Node2D
@export var multiplayerScene : PackedScene
func _ready():
	$UI.OnStartGame.connect(onStartGame)
		
func onStartGame():
	add_child(multiplayerScene.instantiate())
