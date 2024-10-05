extends CharacterBody2D

@export var tmp_target: Node = null

@onready var item = $Item
@onready var item_rest = $ItemRest
@onready var body_sprite = $Body

enum State {
	NO_ACTION,
	MELEE_ATTACK
}

var state: State = State.NO_ACTION

var state_timer = 0.0

var melee_attack_target_pos: Vector2
var melee_attack_target_rot: float

func parabola_one(t: float) -> float:
	t = 2.0 * t - 1.0
	return 1.0 - t * t

func melee_attack(what: Vector2):
	# Only attack if we're not doing something else.
	if state != State.NO_ACTION:
		return
		
	state = State.MELEE_ATTACK
	state_timer = 0.0
	
	melee_attack_target_pos = what
	melee_attack_target_rot = (what - global_position).angle()
	
var target_noise = Vector2.ZERO

func _physics_process(delta):
	# Uncomment this if we want to animate the item
	# Note: Additional latency from the frame being delayed makes this not really work.
	# Probably need to either reparent the item or...?
	#if state == State.NO_ACTION:
		#item.sync_to_physics = false
		#item.global_transform = item_rest.global_transform
	#else:
		## For now...
		#item.sync_to_physics = true
		
	
	if abs(velocity.x) > 64 and sign(velocity.x) != sign(body_sprite.scale.x):
		body_sprite.scale.x *= -1
		# Uncomment to have the items flip when stuff...
		# I guess for now we'll just leave ItemRest not under Body??
		#item.global_position.x = item_rest.global_position.x
	
	if state == State.MELEE_ATTACK:
		state_timer += delta
		var to_t = parabola_one(state_timer)
		# To update both rotation and angle while sync_to_physics is on, we have to do it in
		# one step.
		var new_tform = Transform2D.IDENTITY
		new_tform = new_tform.rotated(lerp_angle(0.0, melee_attack_target_rot + TAU * 0.25, to_t))
		new_tform.origin = lerp(item_rest.global_position, melee_attack_target_pos, to_t)
		item.global_transform = new_tform
		
		if state_timer >= 1.0:
			item.global_transform = item_rest.global_transform
			state = State.NO_ACTION
			state_timer = 0.0
			
	#if Input.is_action_just_pressed("player_right"):
		#melee_attack(tmp_target.global_position)
		
	var target_noise_nosmooth = Vector2.from_angle(randf_range(0, TAU)) * randf_range(0.0, 512.0)
	target_noise += (target_noise_nosmooth - target_noise) * 0.05
		
	var move_target = get_global_mouse_position() + target_noise
	var vel = (move_target - global_position) * 0.8
	velocity = vel.limit_length(128)
	
	# Add impulses for each nearby imp.
	for imp in get_tree().get_nodes_in_group("Players"):
		var to_vec = global_position - imp.global_position
		if to_vec.length_squared() < 72.0 * 72.0:
			var impulse = 1024.0 * to_vec / (to_vec.length_squared() + 0.005)
			#print(impulse)
			velocity += impulse
	
	
	
	move_and_slide()
		
