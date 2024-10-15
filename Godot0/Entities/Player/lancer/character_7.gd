extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var healthbar = $"../UI_manager/HealthBar"
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
var ATTACK_1_DAMAGE = 30
var ATTACK_2_DAMAGE = 50
var dash_power = 500
var enemy = null
var dashing = false
var dir_save
var air:bool
signal facing_direction_changed(facing_right:bool)


func _ready():
	healthbar.init_health(health)

func _physics_process(delta):
	var direction = Input.get_axis("left", "right")
	det_dir(direction)
	gravity_and_jump(delta)
	attack()
	player_controller(direction)

	move_and_slide()
	
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
		
func gravity_and_jump(delta):
	if not is_on_floor():
		air = true
		velocity.y += gravity * delta
	elif jump_count != 0:
		jump_count = 0
		
func player_controller(dir):
	if dashing:
		return
	if dir:
		if Input.is_action_just_pressed("faster"):
			speed = 350
		elif air:
			speed= 100
		else:
			speed = 250
		velocity.x = dir * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		
	if !anyMovement:
		if velocity.x == 0:
			animated_sprite.play("idle")
		else:
			animated_sprite.play("run")
			det_dir(dir)
			
	if Input.is_action_just_pressed("up") and jump_count < jump_max:
		speed = 100
		velocity.y = jump_power
		jump_count += 1 

func attack():
	if Input.is_action_just_pressed("attack") and !anyMovement:
		
		anyMovement = true
		speed = 20
		
		if combo == 0:
			$AttackTimer.start()
			await wait_for_animation("attack_1", 0.7)
			send_damage(ATTACK_1_DAMAGE)
			combo = 1
			
		elif combo == 1 and !$AttackTimer.is_stopped():
			dashing = true
			await wait_for_animation("attack_2", 0.7)
			send_damage(ATTACK_2_DAMAGE)
			combo = 0

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

func send_damage(damage):
	if enemy_inattack_range and enemy:
		var knockback_direction = (enemy.position - position).normalized() * -1
		enemy.take_damage(damage)

		
func player():
	pass

func take_damage(damage_amount):
	if player_alive:
		health -= damage_amount
		anyMovement = true
		await wait_for_animation("damaged", 0.8)
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
