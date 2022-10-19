extends Node2D

onready var animationPlayer: = $AnimationPlayer

func end_bounce():
	animationPlayer.current_animation = 'idle'

func _on_BounceBox_body_entered(body):
	if body is Player:
		var force = 325
		body.state = body.MOVE
		body.dashTimer.stop()
		body.velocity = Vector2.UP.rotated(self.transform.get_rotation())
		body.velocity.y *= force
		if body.velocity.y < 0:
			body.velocity.y = min(body.velocity.y, -150)
		body.velocity.x *= force*2
		body.reset_actions()
		body.reset_double_jumps()
		animationPlayer.current_animation = 'bounce'
