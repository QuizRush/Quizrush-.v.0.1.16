# HealthManager.gd
extends Node

@export var max_health := 100
var current_health : int

func _ready():
	current_health = max_health

func take_damage(amount: int):
	current_health -= amount
	if current_health <= 0:
		die()

func die():
	queue_free()  # Remove the node from the scene
