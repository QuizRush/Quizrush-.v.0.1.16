extends Area2D

@export var player : CharacterBody2D
@export var Enemy : enemy
@export var facing_shape : FacingCollisionShape2D


func _ready():

	if player != null:
		player.connect("facing_direction_changed", Callable(self, "_on_player_facing_direction_changed"))
	else:
		print("Player is not set!")
	if Enemy != null:
		Enemy.connect("facing_direction_changed", Callable(self, "_on_player_facing_direction_changed"))
	else:
		print("Enemy is not set!")

func _on_player_facing_direction_changed(facing_right : bool):
	if facing_right:
		facing_shape.position = facing_shape.facing_right_position
	else:
		facing_shape.position = facing_shape.facing_left_position
