extends AnimatableBody2D

var velocity = Vector2.ZERO

var damage: int = 1

@onready var sprite = $Sprite

# IMPORTANT: ALL  PROJECTILES MUST IMPLEMENT THIS
func hit_target():
	die()

func die():
	var particle = GS.EnemyProjectile1Particle.instantiate()
	particle.position = position
	add_sibling(particle)
	queue_free()

func _physics_process(delta):
	# Animate sprite
	sprite.rotate(0.25 * TAU * delta)
	
	var collide = move_and_collide(velocity * delta)
	
	#if targetted_player != null:
		#var dir = (targetted_player.global_position - global_position).normalized()
		#var new_vel = dir * SPEED
		#
		#velocity = velocity.slerp(new_vel, 0.02)

	# Die when we hit a wall
	if collide != null:
		die()
