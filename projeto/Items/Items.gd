extends Area2D

func _on_anim_animation_finished(anim_name: String) -> void:
	if anim_name == "collected":
		queue_free()

func _on_items_body_entered(body):
	$anim.play("collected")
	$collectedFx.play()
	Events.add_fruit(1)
