extends Area2D

func _on_CollectBox_body_entered(body):
	if body is Player:
		body.reset_actions()
		body.reset_double_jumps()
