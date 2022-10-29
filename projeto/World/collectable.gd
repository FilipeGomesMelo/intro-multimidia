extends Node2D

onready var timer: = $Timer
onready var collectBox: = $CollectBox
onready var animatedSprite: = $AnimatedSprite
onready var audioPlayer: = $AudioStreamPlayer2D

func _on_CollectBox_body_entered(body):
	if body is Player:
		timer.start()
		audioPlayer.play()
		animatedSprite.animation = "collected"
		collectBox.set_collision_mask_bit(1, false) 


func _on_Timer_timeout():
	animatedSprite.animation = "idle"
	animatedSprite.visible = true
	collectBox.set_collision_mask_bit(1, true)
