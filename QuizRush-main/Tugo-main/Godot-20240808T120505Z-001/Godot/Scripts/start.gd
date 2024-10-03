extends Control
@onready var timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer.start()
	timer.start(3.0)
	timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout():
	get_tree().change_scene_to_file("res://Scenes/login.tscn")
