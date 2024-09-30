extends Node
class_name Mode_switcher


@export var current_mode : Mode
@export var modes : Array[Mode]

func _ready():
	print("MODE:", current_mode)
	for child in get_children():
		if(child is State):
			modes.append(child)
			child.connect("interrupt_state", on_state_interrupt_state)
			#
func _physics_process(delta):
	if current_mode.next_mode != null:
		switch_state(current_mode.next_state)
	
	current_mode.state_process(delta)


func switch_state(new_mode : Mode):
	if current_mode != null:
		current_mode.on_exit()
		current_mode.next_mode= null
		
	current_mode = new_mode
	current_mode.on_enter()
	
func _input(event : InputEvent):
	current_mode.state_input(event)
	
func on_state_interrupt_state(new_mode: Mode):
	switch_state(new_mode)
	
	
