extends Node2D

onready var timer: = $Timer
onready var collisionShape: = $CollectBox/CollisionShape2D
onready var animatedSprite: = $AnimatedSprite


func _on_CollectBox_body_entered(body):
	if body is Player:
		timer.start()
		animatedSprite.visible = false
		collisionShape.disabled = true


func _on_Timer_timeout():
	animatedSprite.visible = true
	collisionShape.disabled = false
