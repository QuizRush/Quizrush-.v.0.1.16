extends State

class_name AttackState

@export var return_state : State
@onready var timer1 := $Timer
@onready var timer2 := $Timer2
var damage_amount := 10  # Damage dealt by the attack

func state_input(event : InputEvent):
	if event.is_action_pressed("attack") and timer1.is_stopped():
		timer1.start()
		timer2.start()

func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "attack_1":
		if timer1.is_stopped():
			next_state = return_state
			playback.travel("move")
		else:
			playback.travel("attack_2")
			deal_damage()  # Deal damage on attack animation

	elif anim_name == "attack_2":
		if timer2.is_stopped():
			next_state = return_state
			playback.travel("move")
		else:
			playback.travel("attack_3")

	elif anim_name == "attack_3":
		next_state = return_state
		playback.travel("move")

func deal_damage():
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body is HealthManager:
			body.take_damage(damage_amount)  # Apply damage
