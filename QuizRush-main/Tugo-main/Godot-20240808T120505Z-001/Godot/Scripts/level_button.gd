@tool
extends TextureButton

signal level_selected

@export var level_num = 1
@export var locked: bool = true:
	set(value):
		locked = value
		level_locked() if locked else level_unlocked()

func level_locked() -> void:
	level_state(true)
	$Labell.text ="Locked"
	
func level_unlocked() -> void:
	level_state(false)
	$Labell.text ="Level "+ str(level_num)

func level_state(value: bool) -> void:
	disabled = value
	$Labell.visible = not value

func _on_pressed():
	level_selected.emit(level_num)
