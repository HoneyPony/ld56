extends AnimatableBody2D
class_name SplitBuff

var velocity = Vector2.ZERO
var projectile_source = null

@export var is_buff = false
var still_has_split = true

@onready var sprite = $Sprite

# IMPORTANT: ALL  PROJECTILES MUST IMPLEMENT THIS
func hit_target(target):
	still_has_split = false
	die()
	
func killed_target(target):
	pass

func die():
	var particle = null
	if is_buff:
		particle = GS.BuffParticle.instantiate()
	else:
		particle = GS.EnemyProjectile1Particle.instantiate()
	particle.position = position
	add_sibling(particle)
	queue_free()

func _physics_process(delta):
	var collide = move_and_collide(velocity * delta)
	sprite.rotate(-TAU * delta)

	# Die when we hit a wall
	if collide != null:
		die()
