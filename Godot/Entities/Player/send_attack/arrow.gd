extends Area2D

@export var speed = 400
var damagez

var direction:Vector2
var self_

func _ready():
	await get_tree().create_timer(2).timeout
	queue_free()

func set_direction(bulletDirection: Vector2, arrow: String , self__ ,damage):
	damagez = damage
	self_ = self__
	$AnimatedSprite2D.play(arrow)
	direction = bulletDirection
	rotation_degrees = rad_to_deg(global_position.angle_to_point(global_position + direction))


func _physics_process(delta):
	global_position += direction * speed * delta
	
func magic():
	pass
	
func _on_body_entered(body):
	if body.has_method("take_damage") :
		if self_ != body:
			body.take_damage(damagez)
			queue_free()
