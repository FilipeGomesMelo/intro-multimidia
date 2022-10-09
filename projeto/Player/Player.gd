extends KinematicBody2D
class_name Player

enum {
	MOVE,
	CLIMB,
	DASH
}

export(Resource) var moveConfig = \
	preload("res://Player/Resources/DefaultPlayerMovementConfig.tres") \
		as PlayerMovementConfig

var velocity = Vector2.ZERO
var state = MOVE
var buffered_jump = false
var coyote_jump = false
var wall_coyote_jump = 0

onready var double_jump_count = moveConfig.DOUBLE_JUMPS
onready var animatedSprite: = $AnimatedSprite
onready var ladderCheck: = $LadderCheck
onready var jumpBufferTimer: = $BufferJumpTimer
onready var coyoteJumpTimer: = $CoyoteJumpTimer
onready var dashTimer: = $DashTimer
onready var wallCoyoteJumpTimer: = $WallCoyoteJumpTimer
onready var remoteTransform2D: = $RemoteTransform2D
onready var leftWallCheck: = $LeftWallCheck
onready var rightWallCheck: = $RightWallCheck

var old_pos = Vector2.ZERO

func _ready():
	animatedSprite.frames = load("res://Player/Resources/PlayerGreeSkin.tres")

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_axis("ui_left", "ui_right")
	input_vector.y = Input.get_axis("ui_up", "ui_down")
	
	match state:
		MOVE: move_state(input_vector, delta)
		CLIMB: climb_state(input_vector)
		DASH: dash_state()
	old_pos = global_position

func move_state(input_vector, delta):
	if is_on_ladder() and Input.is_action_just_pressed("ui_up"):
		state = CLIMB
	
	apply_gravity()
	if input_vector.x == 0:
		animatedSprite.animation = "Idle"
		apply_friction()
	else:
		animatedSprite.animation = "Run"
		animatedSprite.flip_h = input_vector.x > 0
		apply_acceleration(input_vector.x)
	
	if is_on_floor():
		reset_double_jumps()
	else:
		animatedSprite.animation = "Jump"
	
	if is_on_wall():
		reset_double_jumps()
	
	var was_on_floor = is_on_floor()
	var was_on_wall = 0
	if leftWallCheck.is_colliding():
		was_on_wall = -1
	elif rightWallCheck.is_colliding():
		was_on_wall = 1
	velocity = move_and_slide(velocity, Vector2.UP)
	
	if Input.is_action_just_pressed("left_click"):
		var mouse_click_vector = get_global_mouse_position() - self.global_position
		velocity = 350 * mouse_click_vector.normalized()
		state = DASH
		dashTimer.start(0.25)
	
	if can_jump():
		input_jump(delta)
	else:
		if leftWallCheck.is_colliding() or wall_coyote_jump == -1:
			if input_wall_jump(delta, 1):
				was_on_wall = 0
		elif rightWallCheck.is_colliding() or wall_coyote_jump == 1:
			if input_wall_jump(delta, -1):
				was_on_wall = 0
		else:
			input_jump_release()
			input_double_jump()
		buffer_jump()
	
	# Just landed
	if is_on_floor() and not was_on_floor:
		animatedSprite.animation = "Run"
		animatedSprite.frame = 1
	
	# Just left the floor
	if not is_on_floor() and was_on_floor and velocity.y >= 0:
		coyote_jump = true
		coyoteJumpTimer.start()
	
	# Just left the wall
	if not is_on_wall() and was_on_wall:
		wall_coyote_jump = was_on_wall
		wallCoyoteJumpTimer.start()

func climb_state(input_vector):
	if not is_on_ladder():
		state = MOVE
	
	reset_double_jumps()
	if input_vector.length() != 0:
		animatedSprite.animation = "Run"
	else:
		animatedSprite.animation = "Idle"
	
	velocity = input_vector * moveConfig.CLIMB_SPEED
	velocity = move_and_slide(velocity, Vector2.UP)

func dash_state():
	velocity = move_and_slide(velocity, Vector2.UP)

func player_die():
	SoundPlayer.play_sound(SoundPlayer.HURT)
	queue_free()
	Events.emit_signal("player_died")

func connect_camera(camera: Camera2D):
	var camera_path = camera.get_path()
	remoteTransform2D.remote_path = camera_path

func is_on_ladder():
	var collider = ladderCheck.get_collider()
	return collider is Ladder

func can_jump():
	return is_on_floor() or coyote_jump

func reset_double_jumps():
	double_jump_count = moveConfig.DOUBLE_JUMPS

func input_jump(delta):
	if Input.is_action_just_pressed("ui_up") or buffered_jump:
		buffered_jump = false
		coyote_jump = false
		velocity.y = moveConfig.JUMP_FORCE
		velocity.x = ((global_position - old_pos)/delta).x

func input_wall_jump(delta, direction):
	if Input.is_action_just_pressed("ui_up") or buffered_jump:
		buffered_jump = false
		coyote_jump = false
		wall_coyote_jump = 0
		velocity.y = moveConfig.WALL_JUMP_V_FORCE
		velocity.x = moveConfig.WALL_JUMP_H_FORCE * direction
		return true
	return false

func input_jump_release():
	if Input.is_action_just_released("ui_up") \
			and velocity.y < moveConfig.JUMP_RELEASE_FORCE:
		velocity.y = velocity.y * .5

func input_double_jump():
	if Input.is_action_just_pressed("ui_up") and double_jump_count > 0:
		velocity.y = moveConfig.JUMP_FORCE
		double_jump_count -= 1

func buffer_jump():
	if Input.is_action_just_pressed("ui_up"):
		buffered_jump = true
		jumpBufferTimer.start()

func apply_gravity():
	if velocity.y > 0:
		if not is_on_wall():
			velocity.y += moveConfig.BASE_GRAVITY \
				+ moveConfig.ADDITIONAL_FALLING_GRAVITY
		else:
			velocity.y += moveConfig.WALL_SLIDE_GRAVITY
	else:
		velocity.y += moveConfig.BASE_GRAVITY
	if is_on_wall():
		velocity.y = min(velocity.y, moveConfig.MAX_WALL_SLIDE_SPEED)
	else:
		velocity.y = min(velocity.y, moveConfig.MAX_FALL_SPEED)

func apply_friction():
	velocity.x = move_toward(velocity.x, 0, moveConfig.FRICTION)

func apply_acceleration(direction: int):
	var max_speed = 0
	if is_on_floor():
		max_speed = moveConfig.MAX_SPEED
	else:
		max_speed = moveConfig.MAX_AIR_SPEED
	
	if sign(velocity.x) == sign(direction):
		# Moving in the same direction player is holding
		if abs(velocity.x) <= abs(max_speed):
			# Moving slower than it should, accelerating
			velocity.x = move_toward(
				velocity.x,
				max_speed * direction,
				moveConfig.ACCELERATION)
		else:
			# Moving faster than it should, decelerating
			velocity.x = move_toward(
				velocity.x,
				max_speed * direction,
				moveConfig.DECCELERATION)
	else:
		# Moving in the oposite direction player is holding
		velocity.x = move_toward(
			velocity.x,
			max_speed * direction,
			max(moveConfig.ACCELERATION,
				moveConfig.FRICTION))

func _on_JumpBufferTimer_timeout():
	buffered_jump = false

func _on_CoyoteJumpTimer_timeout():
	coyote_jump = false

func _on_WallCoyoteJumpTimer_timeout():
	wall_coyote_jump = 0

func _on_DashTimer_timeout():
	state = MOVE
	velocity.y = 0
	var x_sign = sign(velocity.x)
	velocity.x = min(abs(velocity.x), moveConfig.MAX_AIR_SPEED) * x_sign
