extends KinematicBody2D
class_name Player

enum {
	MOVE,
	CLIMB
}

export(Resource) var moveConfig = \
	preload("res://Player/Resources/DefaultPlayerMovementConfig.tres") \
		as PlayerMovementConfig

var velocity = Vector2.ZERO
var state = MOVE
var buffered_jump = false
var coyote_jump = false

onready var double_jump_count = moveConfig.DOUBLE_JUMPS
onready var animatedSprite: = $AnimatedSprite
onready var ladderCheck: = $LadderCheck
onready var jumpBufferTimer: = $BufferJumpTimer
onready var coyoteJumpTimer: = $CoyoteJumpTimer
onready var remoteTransform2D: = $RemoteTransform2D

func _ready():
	animatedSprite.frames = load("res://Player/Resources/PlayerGreeSkin.tres")

func _physics_process(delta):	
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_axis("ui_left", "ui_right")
	input_vector.y = Input.get_axis("ui_up", "ui_down")
	
	match state:
		MOVE: move_state(input_vector)
		CLIMB: climb_state(input_vector)

func move_state(input_vector):
	if is_on_ladder() and Input.is_action_pressed("ui_up"):
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
	
	if can_jump():
		input_jump()
	else:
		input_jump_release()
		input_double_jump()
		buffer_jump()
	
	var was_on_floor = is_on_floor()
	velocity = move_and_slide(velocity, Vector2.UP)
	
	# Just landed
	if is_on_floor() and not was_on_floor:
		animatedSprite.animation = "Run"
		animatedSprite.frame = 1
	
	# Just left the floor
	if not is_on_floor() and was_on_floor and velocity.y >= 0:
		coyote_jump = true
		coyoteJumpTimer.start()

func climb_state(input_vector):
	if not is_on_ladder():
		state = MOVE
	
	if input_vector.length() != 0:
		animatedSprite.animation = "Run"
	else:
		animatedSprite.animation = "Idle"
	
	velocity = input_vector * 50
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
	
func input_jump():
	if Input.is_action_just_pressed("ui_up") or buffered_jump:
		buffered_jump = false
		coyote_jump = false
		velocity.y = moveConfig.JUMP_FORCE
		SoundPlayer.play_sound(SoundPlayer.JUMP)

func input_jump_release():
	if not Input.is_action_pressed("ui_up") \
			and velocity.y < moveConfig.JUMP_RELEASE_FORCE:
		velocity.y = moveConfig.JUMP_RELEASE_FORCE

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
		velocity.y += moveConfig.BASE_GRAVITY \
			+ moveConfig.ADDITIONAL_FALLING_GRAVITY
	else:
		velocity.y += moveConfig.BASE_GRAVITY
	velocity.y = min(velocity.y, moveConfig.MAX_FALL_SPEED)

func apply_friction():
	velocity.x = move_toward(velocity.x, 0, moveConfig.FRICTION)

func apply_acceleration(direction: int):
	velocity.x = move_toward(
		velocity.x,
		moveConfig.MAX_SPEED * direction,
		moveConfig.ACCELERATION)

func _on_JumpBufferTimer_timeout():
	buffered_jump = false

func _on_CoyoteJumpTimer_timeout():
	coyote_jump = false
