extends CharacterBody2D

const speed = 50

@onready var sprite :Sprite2D = $Sprite2D
@onready var animation_tree := $AnimationTree
@onready var bot_state_machine := $CharacterStateMachine

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction : Vector2 = Vector2.ZERO

func _ready():
	animation_tree.active = true


func _process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	
	var x_dif = Global.player_pos.x - position.x
	if abs(x_dif) <= 100:
		direction.x = 0
	elif x_dif > 100:
		direction.x = 1
	else:
		direction.x = -1
	
	if direction.x != 0 and bot_state_machine.check_if_can_move():
		velocity.x = direction.x * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
	
	move_and_slide()
	update_animation_parameter()
	if bot_state_machine.current_state != bot_state_machine.states[2]:
		update_facing_direction()
	

func update_animation_parameter():
	animation_tree.set("parameters/move/blend_position", direction.x)

func update_facing_direction():
	if direction.x > 0:
		sprite.flip_h = false
	elif direction.x < 0:
		sprite.flip_h = true
