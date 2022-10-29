extends Area2D

export(String, FILE, "*.tscn") var target_level_path = ""

var over_player = false

func go_to_next_room():
	Transitions.play_exit_transition()
	get_tree().paused = true
	yield(Transitions, "transition_completed")
	get_tree().change_scene(target_level_path)
	Transitions.play_enter_transition()
	get_tree().paused = false
	yield(Transitions, "transition_completed")

func _process(delta):
	if not over_player: return
	if Input.is_action_just_pressed("ui_down"):
		if target_level_path.empty(): return
		go_to_next_room()

func _on_porta_body_entered(body):
	if not body is Player: return
	over_player = true

func _on_porta_body_exited(body):
	over_player = false
