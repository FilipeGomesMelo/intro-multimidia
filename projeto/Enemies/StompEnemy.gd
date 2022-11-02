extends KinematicBody2D

enum {HOVER, FALL, LAND, RISE}

var state = HOVER

onready var start_position: = Vector2.ZERO
onready var timer: = $Timer
onready var idleWaitTimer: = $IdleWaitTimer
onready var raycast: = $RayCastDown
onready var animated_sprite: = $AnimatedSprite
onready var collisionShape: = $CollisionDown

onready var particles: = $ParticlesDown
onready var colissionPoint: = $DownPoint
onready var soundPlayer: = $AudioStreamPlayer2D

onready var playerCheck: = $PlayerCheck

enum SLAM_DIRECTION {
	DOWN,
	LEFT,
	RIGHT,
	UP
}

export(SLAM_DIRECTION) var slam_direction
export(float) var slam_speed = 200
export(float) var return_speed = 50

var player_targeted = false
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
			playerCheck.rotation_degrees = 90
		SLAM_DIRECTION.RIGHT:
			direction = Vector2.RIGHT
			particles = $ParticlesRight
			colissionPoint = $RightPoint
			raycast = $RayCastRight
			collisionShape = $CollisionRight
			playerCheck.rotation_degrees = -90
		SLAM_DIRECTION.UP:
			direction = Vector2.UP
			particles = $ParticlesUp
			colissionPoint = $UpPoint
			raycast = $RayCastUP
			collisionShape = $CollisionUp
			playerCheck.rotation_degrees = 180
		_: 
			direction =Vector2.DOWN
			particles = $ParticlesDown
			colissionPoint = $DownPoint
			raycast = $RayCastDown
			collisionShape = $CollisionDown
			playerCheck.rotation_degrees = 0

func _physics_process(delta):
	match (state):
		HOVER: hover_state()
		FALL: fall_state(delta)
		LAND: land_state()
		RISE: rise_state(delta)

func hover_state():
	if player_targeted and idleWaitTimer.time_left == 0:
		state = FALL

func fall_state(delta):
	animated_sprite.play('falling')
	collisionShape.disabled = true
	position += (slam_speed * delta) * direction
	if raycast.is_colliding():
		var collided_with = raycast.get_collider()
		if not collided_with is KinematicBody2D:
			var collision_point = raycast.get_collision_point()
			position.y = collision_point.y + (global_position.y - colissionPoint.global_position.y)
			position.x = collision_point.x + (global_position.x - colissionPoint.global_position.x)
		state = LAND
		soundPlayer.play()
		Events.emit_signal("shake_camera", 0.1 * self.scale.x, self.scale.x + 1.5)
		timer.start(1.0)
		particles.emitting = true
		collisionShape.disabled = false

func land_state():
	if timer.time_left == 0:
		state = RISE

func rise_state(delta):
	animated_sprite.play('idle')
	position.y = move_toward(position.y, start_position.y, return_speed * delta)
	position.x = move_toward(position.x, start_position.x, return_speed * delta)
	if position == start_position:
		state = HOVER
		idleWaitTimer.start()


func _on_PlayerCheck_body_entered(body):
	if body is Player:
		player_targeted = true


func _on_PlayerCheck_body_exited(body):
	if body is Player:
		player_targeted = false
