extends Area2D

onready var sprite: = $apple
onready var animationPlayer: = $anim
onready var soundPlayer = $collectedFx

func _ready():
	Events.connect("player_died", self, "_on_player_died")

func _on_anim_animation_finished(anim_name: String) -> void:
	sprite.visible = false

func _on_player_died():
	sprite.visible = true
	set_deferred("monitoring", true)
	animationPlayer.play("motion")

func _on_items_body_entered(body):
	if body is Player:
		set_deferred("monitoring", false)
		animationPlayer.play("collected")
		soundPlayer.play()
		Events.add_fruit(1)
