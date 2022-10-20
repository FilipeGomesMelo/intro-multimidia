extends Control

func _ready():
	$Label.visible = false

func _process(delta):
	if Input.is_action_just_pressed("pause"):
		if get_tree().paused == false:
			SoundPlayer.play_sound(SoundPlayer.PAUSE)
			get_tree().paused = true
			$Label.visible = true
		else:
			SoundPlayer.play_sound(SoundPlayer.PAUSE)
			get_tree().paused = false
			$Label.visible = false
