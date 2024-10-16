extends CharacterBody2D


@onready var animated_sprite = $AnimatedSprite2D
@onready var healthbar = $HealthBar
@onready var camera = $Camera2D
var speed = 250.0
const jump_power = -300.0
var jump_count = 0
var jump_max = 2
var gravity = 900
var health = 100
var player_alive = true
var enemy_inattack_range = false
var attack_cooldown_stopped = false
var anyMovement = false
var combo = 0
var ATTACK_1_DAMAGE = 5
var ATTACK_2_DAMAGE = 6
var special_damage = 10
var mana = 0
var dash_power = 500
var enemy = null
var dashing = false
var dir_save
var air:bool



signal facing_direction_changed(facing_right:bool)


func _ready():
	healthbar.init_health(health)
	$MultiplayerSynchronizer.set_multiplayer_authority(str(name).to_int())
	if multiplayer.get_unique_id() == get_multiplayer_authority():
		camera.make_current()


func _physics_process(delta):
	if $MultiplayerSynchronizer.get_multiplayer_authority() == multiplayer.get_unique_id():
		var direction = Input.get_axis("left", "right")
		det_dir(direction)
		gravity_and_jump(delta)
		attack()
		player_controller(direction , delta)
		move_and_slide()

		rpc("sync_position", position) 



@rpc
func sync_position(pos: Vector2):
	position = pos
	
func det_dir(dir):
	dir_save = dir
	if dir == 1:
		animated_sprite.flip_h = false
		$coll_right.visible = true
		$coll_left.visible = false
	if dir == -1:
		animated_sprite.flip_h = true
		$coll_right.visible = false
		$coll_left.visible = true
	emit_signal("facing_direction_changed", !animated_sprite.flip_h)
	rpc("sync_animation_and_flip", animated_sprite.animation, animated_sprite.flip_h, position)	
	
func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())
	
func gravity_and_jump(delta):
	if not is_on_floor():
		air = true
		velocity.y += gravity * delta
	elif jump_count != 0:
		jump_count = 0
		
func player_controller(dir , deltta):
	if dashing:
		return
	if anyMovement:
		return
	if dir != 0:
		if Input.is_action_pressed("fast_run_key"):
			speed = 400
			animated_sprite.play("fast_run")
		else:
			speed = 250
			if is_on_floor():
				animated_sprite.play("run")
				det_dir(dir)
		velocity.x = dir * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed * 3 * deltta)

	if is_on_floor() and velocity.x == 0:
		animated_sprite.play("idle")

	if Input.is_action_just_pressed("up") and jump_count < jump_max:
		velocity.y = jump_power
		jump_count += 1

	if !anyMovement and is_on_floor():
		speed = 250



func attack():
	if Input.is_action_just_pressed("attack") and !anyMovement:
		
		anyMovement = true
		speed = 20
		
		if combo == 0 and mana != 4:
			$AttackTimer.start()
			await wait_for_animation("attack_1", 0.7)
			send_damage(ATTACK_1_DAMAGE)
			combo = 1
			mana +=1
			$Node2D.increase_mana()	
			rpc("sync_animation_and_flip", "attack_1", animated_sprite.flip_h, position)
			attack_cooldown_stopped = false
		elif combo == 1 and not attack_cooldown_stopped and mana != 4:
			dashing = true
			await wait_for_animation("attack_2", 0.7)
			send_damage(ATTACK_2_DAMAGE)
			combo = 0
			mana+=1
			$Node2D.increase_mana()
			rpc("sync_animation_and_flip", "attack_2", animated_sprite.flip_h, position)
			attack_cooldown_stopped = true
			$AttackTimer.stop()
		else:
			dashing = true
			await wait_for_animation("attack_3", 0.75)
			send_damage(special_damage)
			combo = 0
			mana = 0
			rpc("sync_animation_and_flip", "attack_3", animated_sprite.flip_h, position)
			$Node2D.reset_mana()
			$AttackTimer.stop()

		anyMovement = false

func perform_dash():
	if dir_save != 0:
		velocity.x = dir_save * dash_power
		dashing = true
	await get_tree().create_timer(0.5).timeout
	dashing = false

func wait_for_animation(anim: String, duration: float) -> void:
	animated_sprite.play(anim)
	if dashing :
		perform_dash()
	await get_tree().create_timer(duration).timeout
	rpc("sync_animation_and_flip", anim, animated_sprite.flip_h, position)

func send_damage(damage):
	if enemy_inattack_range and enemy:
		var knockback_direction = (enemy.position - position).normalized() * -1
		enemy.take_damage(damage)
		rpc("sync_animation_and_flip", animated_sprite.animation, animated_sprite.flip_h, position)
		
@rpc
func sync_animation_and_flip(anim: String, flip_h: bool, pos: Vector2):
	animated_sprite.play(anim)
	animated_sprite.flip_h = flip_h
	position = pos

func player():
	pass

@rpc
func sync_health(new_health: int):
	health = new_health
	healthbar.update_health(new_health) 

func take_damage(damage_amount):
	if player_alive:
		health -= damage_amount
		anyMovement = true
		await wait_for_animation("damaged", 0.8)
		rpc("sync_health", health)
		is_death()
		anyMovement = false

		

func is_death():
	if health <= 0:
		player_alive = false
		health = 0
		await wait_for_animation("death", 0.8)
		self.queue_free()
	else:
		healthbar.health = health
	

func _on_player_hitbox_body_entered(body):
	if body.has_method("take_damage") and self != body:
		enemy_inattack_range = true
		enemy = body

func _on_player_hitbox_body_exited(body):
	if body == enemy:
		enemy_inattack_range = false
		enemy = null
		
func _on_attack_timer_timeout():
	combo = 0
	attack_cooldown_stopped = true

