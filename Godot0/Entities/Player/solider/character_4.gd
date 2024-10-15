extends CharacterBody2D

@onready var animated_sprite = $AnimatedSprite2D
@onready var healthbar = $"../UI_manager/HealthBar"
@onready var maker_2d = $Marker2D
@onready var shoot_speed_timer = $shootSpeedTimer
@export var shootSpeed = 1.0

const BULLET = preload("res://Entities/Player/send_attack/magic.tscn")


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
var KNOCKBACK_DAMAGE_1 = 100
var KNOCKBACK_DAMAGE_2 = 300
var ATTACK_1_DAMAGE = 30
var ATTACK_2_DAMAGE = 50
var canShoot = true
var bulletDirection = Vector2(1,0)

var enemy = null

signal facing_direction_changed(facing_right:bool)


func _ready():
	shoot_speed_timer.wait_time = 1.0/ shootSpeed
	healthbar.init_health(health)

func _physics_process(delta):
	var direction = Input.get_axis("left", "right")
	det_dir(direction)
	gravity_and_jump(delta)
	attack()
	player_controller(direction)

	move_and_slide()
	
func det_dir(dir):
	if dir == 1:
		animated_sprite.flip_h = false
	if dir == -1:
		animated_sprite.flip_h = true
		
	emit_signal("facing_direction_changed", !animated_sprite.flip_h)
		
func gravity_and_jump(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	elif jump_count != 0:
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
				animated_sprite.play("idle")
			else:
				animated_sprite.play("run")
				det_dir(dir)
		else:
			speed = 100
			
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
			animated_sprite.play("attack_1")
			deal_damage_to_enemy(ATTACK_1_DAMAGE, KNOCKBACK_DAMAGE_1)
			combo = 1
			attack_cooldown_stopped = false
		elif combo == 1 and not attack_cooldown_stopped:
			animated_sprite.play("attack_2")
			await get_tree().create_timer(0.2).timeout
			deal_damage_to_enemy(ATTACK_2_DAMAGE, KNOCKBACK_DAMAGE_2)
			combo = 0
			attack_cooldown_stopped = true
			$AttackTimer.stop()

		await get_tree().create_timer(0.7).timeout
		anyMovement = false


func deal_damage_to_enemy(damage, knockback_damage):
	if enemy_inattack_range and enemy:
		var knockback_direction = (enemy.position - position).normalized() * -1
		enemy.take_damage(damage, knockback_direction)

		
func player():
	pass

func take_damage_player(damage_amount):
	healthbar.visible = true
	health -= damage_amount
	if health <= 0:
		player_alive = false
		health = 0
		$AnimatedSprite2D.play("death")
		await get_tree().create_timer(1).timeout
		self.queue_free()

	healthbar.health = health

func shoot():
	if canShoot:
		canShoot = false
		shoot_speed_timer.start()
		
		var Bullet_node = BULLET.instantiate()
		
		Bullet_node.set_direction(bulletDirection)
		get_tree().root.add_child(Bullet_node)
		Bullet_node.global_position = maker_2d.global_position
		
func _on_shoot_speed_timer_timeout():
	canShoot = true
	
func setup_direction(direction):
	bulletDirection = direction
	if direction.x > 0:
		scale.x = 1
		
	elif direction.x < 0:
		scale.x = -1	

func _on_player_hitbox_body_entered(body):
	if body.has_method("take_damage"):
		enemy_inattack_range = true
		enemy = body

func _on_player_hitbox_body_exited(body):
	if body == enemy:
		enemy_inattack_range = false
		enemy = null


func _on_attack_timer_timeout():
	combo = 0
	attack_cooldown_stopped = true
