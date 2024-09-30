extends CharacterBody2D
class_name Player
@export var speed := 200.0

@onready var sprite : Sprite2D = $Sprite2D
@onready var animation_tree : AnimationTree = $AnimationTree
@onready var state_machine : CharacterStateMachine = $CharacterStateMachine

signal facing_direction_changed(facing_right : bool)

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var direction := Vector2.ZERO
var last_animation : String = "idle"

func _ready():
	animation_tree.active = true
	
func _physics_process(delta):
	if name == str(multiplayer.get_unique_id()):
		if not is_on_floor():
			velocity.y += gravity * delta
		direction = Input.get_vector("left", "right", "up", "down")
		if direction.x != 0 and state_machine.check_if_can_move():
			velocity.x = direction.x * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
		move_and_slide()
		update_animation()
		syncPos.rpc(global_position, direction.x, sprite.flip_h)

@rpc("any_peer")
func syncPos(p, dir_x, flip_h):
	global_position = p
	direction.x = dir_x
	sprite.flip_h = flip_h

@rpc("any_peer")
func syncAnimation(animation_name):
	$AnimationPlayer.play(animation_name)

func update_animation():
	var new_animation = ""
	if direction.x > 0:
		sprite.flip_h = false
		emit_signal("facing_direction_changed", true)
		new_animation = "walk"
	elif direction.x < 0:
		sprite.flip_h = true
		emit_signal("facing_direction_changed", false)
		new_animation = "walk"
	else:
		if is_on_floor():
			new_animation = "idle"
	if new_animation != last_animation:
		last_animation = new_animation
		$AnimationPlayer.play(new_animation)
		syncAnimation.rpc(new_animation)
