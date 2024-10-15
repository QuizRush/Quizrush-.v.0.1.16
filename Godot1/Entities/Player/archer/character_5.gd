extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var healthbar = $HealthBar
@onready var maker_2d = $Marker2D
@onready var shoot_speed_timer = $shootSpeedTimer
@onready var camera = $Camera2D

@export var shootSpeed = 1.0
const BULLET = preload("res://Entities/Player/send_attack/arrow.tscn")

var speed = 250.0
const jump_power = -300.0
var jump_count = 0
var jump_max = 2
var gravity = 900
var health = 100
var player_alive = true
var anyMovement = false
var combo = 0
var damage_ = 15
var bulletDirection = Vector2(1, 0)
var arrow = "arrow_2"
var can_attack = true


func _ready():
	shoot_speed_timer.wait_time = 1.0 / shootSpeed
	healthbar.init_health(health)
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())
	can_attack = true
	if multiplayer.get_unique_id() == get_multiplayer_authority():
		camera.make_current()


func _physics_process(delta):
	if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		var direction = Input.get_axis("left", "right")
		det_dir(direction)
		gravity_and_jump(delta)
		attack()
		player_controller(direction)
		move_and_slide()

@rpc
func sync_position(pos: Vector2):
	position = pos

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func det_dir(dir):
	if dir != 0:
		bulletDirection = Vector2(dir, 0)
		animated_sprite.flip_h = dir == -1
		rpc("sync_flip", animated_sprite.flip_h)

@rpc
func sync_flip(flip_h: bool):
	animated_sprite.flip_h = flip_h

func gravity_and_jump(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		jump_count = 0

func player_controller(dir):
	if dir:
		velocity.x = dir * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)

	if !anyMovement:
		if is_on_floor():
			speed = 250
			if velocity.x == 0:
				wait_for_animation("idle", 0.2)  # Short duration for idle
			else:
				wait_for_animation("run", 0.2)   # Short duration for running
				det_dir(dir)
		else:
			speed = 100
			wait_for_animation("idle", 0.2)


	if Input.is_action_just_pressed("up") and jump_count < jump_max:
		speed = 100
		velocity.y = jump_power
		jump_count += 1

func attack():
	if Input.is_action_just_pressed("attack") and !anyMovement and can_attack:
		anyMovement = true
		can_attack = false  # Prevent further attacks until current one finishes

		if combo != 4 and $AttackTimer.is_stopped():
			$AttackTimer.start()
			await wait_for_animation("attack_1", 0.7)  # Duration of attack 1
			shoot()
			combo += 1
			$Node2D.increase_mana()
		elif combo == 4 and $AttackTimer.is_stopped():
			$AttackTimer.start()
			await wait_for_animation("attack_2", 0.8)  # Duration of attack 2
			shoot()
			combo = 0
			$Node2D.reset_mana()

		await get_tree().create_timer(0.2).timeout  # Delay before allowing next attack
		can_attack = true  # Allow next attack

		anyMovement = false

func wait_for_animation(anim: String, duration: float) -> void:
	animated_sprite.animation = anim  # Set the animation
	animated_sprite.play()  # Play the specified animation
	rpc("sync_animation_and_flip", anim, animated_sprite.flip_h, position)  # Sync animation
	await get_tree().create_timer(duration).timeout  # Wait for the animation duration

@rpc
func sync_animation(anim: String):
	if animated_sprite.animation != anim:  # Avoid unnecessary calls
		animated_sprite.play(anim)

func shoot():
	# Notify all clients to create the arrow
	rpc("rpc_spawn_arrow", maker_2d.global_position, bulletDirection, arrow, damage_)
	# Optionally, create the arrow locally for instant feedback (optional)
	spawn_arrow(maker_2d.global_position, bulletDirection, arrow, damage_)

@rpc
func rpc_spawn_arrow(position: Vector2, direction: Vector2, arrow_name: String, damage_amount: int):
	spawn_arrow(position, direction, arrow_name, damage_amount)

func spawn_arrow(position: Vector2, direction: Vector2, arrow_name: String, damage_amount: int):
	var Bullet_node = BULLET.instantiate()
	Bullet_node.set_direction(direction, arrow_name, self, damage_amount)
	get_tree().root.add_child(Bullet_node)
	Bullet_node.global_position = position

func take_damage(damage_amount: int):
	health -= damage_amount  # Reduce health by the damage amount
	print("Damage Taken:", damage_amount)  # Print the amount of damage taken
	print("Current Health:", health)  # Print the current health after damage
	anyMovement = true
	await wait_for_animation("damaged", 0.8)  # Play damage animation
	await is_death()  # Check if the player is dead
	anyMovement = false

func is_death():
	if health <= 0:
		player_alive = false
		health = 0
		await wait_for_animation("death", 0.8)
		queue_free()  # Remove the player from the scene
	else:
		healthbar.health = health  # Update the health bar UI

@rpc
func sync_animation_and_flip(anim: String, flip_h: bool, pos: Vector2):
	sync_animation(anim)  # Sync the animation on remote clients
	animated_sprite.flip_h = flip_h
	position = pos  # Update position if necessary
