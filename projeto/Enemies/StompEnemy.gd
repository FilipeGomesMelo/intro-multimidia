extends KinematicBody2D

enum {HOVER, FALL, LAND, RISE}

var state = HOVER

onready var start_position: = Vector2.ZERO
onready var timer: = $Timer
onready var raycast: = $RayCastDown
onready var animated_sprite: = $AnimatedSprite
onready var collisionShape: = $CollisionDown

onready var particles: = $ParticlesDown
onready var colissionPoint: = $DownPoint

enum SLAM_DIRECTION {
	DOWN,
	LEFT,
	RIGHT,
	UP
}

export(SLAM_DIRECTION) var slam_direction

var direction = Vector2.ZERO

func _ready():
	start_position = position
	match (slam_direction):
		SLAM_DIRECTION.LEFT:
			direction = Vector2.LEFT
			particles = $ParticlesLeft
			colissionPoint = $LeftPoint
			raycast = $RayCastLeft
			collisionShape = $CollisionLeft
		SLAM_DIRECTION.RIGHT:
			direction = Vector2.RIGHT
			particles = $ParticlesRight
			colissionPoint = $RightPoint
			raycast = $RayCastRight
			collisionShape = $CollisionRight
		SLAM_DIRECTION.UP:
			direction = Vector2.UP
			particles = $ParticlesUp
			colissionPoint = $UpPoint
			raycast = $RayCastUP
			collisionShape = $CollisionUp
		_: 
			direction =Vector2.DOWN
			particles = $ParticlesDown
			colissionPoint = $DownPoint
			raycast = $RayCastDown
			collisionShape = $CollisionDown

func _physics_process(delta):
	match (state):
		HOVER: hover_state()
		FALL: fall_state(delta)
		LAND: land_state()
		RISE: rise_state(delta)

func hover_state():
	state = FALL

func fall_state(delta):
	animated_sprite.play('falling')
	collisionShape.disabled = true
	position += (200 * delta) * direction
	if raycast.is_colliding():
		var collision_point = raycast.get_collision_point()
		position.y = collision_point.y + (global_position.y - colissionPoint.global_position.y)
		state = LAND
		timer.start(1.0)
		particles.emitting = true
		collisionShape.disabled = false

func land_state():
	if timer.time_left == 0:
		state = RISE

func rise_state(delta):
	animated_sprite.play('idle')
	position.y = move_toward(position.y, start_position.y, 50 * delta)
	position.x = move_toward(position.x, start_position.x, 50 * delta)
	if position == start_position:
		state = HOVER
