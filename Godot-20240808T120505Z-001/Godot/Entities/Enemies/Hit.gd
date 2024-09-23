extends State

class_name HitState

@export var damageable : Damageable
@export var bot_state_machine : CharacterStateMachine
@export var dead_state : State
@export var return_state : State
var taking_damage = false
func _ready():
	damageable.connect("on_hit", on_damageable_hit)




func on_damageable_hit(node : Node, damage_amount : int):
	taking_damage = true
	if (damageable.health > 0):
		emit_signal("interrupt_state", self)
	elif(damageable.health == 0):
		emit_signal("interrupt_state", dead_state)
		playback.travel("die")
	


func _on_animation_tree_animation_finished(anim_name):
	if anim_name == "die":
		print("PPPPPis")
		next_state = dead_state
		bot_state_machine.current_state.on_enter()
