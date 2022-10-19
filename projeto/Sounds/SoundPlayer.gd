extends Node

const HURT = preload("res://Sounds/hurt.wav")
const JUMP = preload("res://Sounds/jump.wav")
const PULAR = preload("res://Sounds/pular (1).wav")
const PAUSE = preload("res://Sounds/pause.wav")
const DASHE = preload("res://Sounds/dashe.wav")

onready var audioPlayers = $AudioPlayers

func play_sound(sound):
	for audioStreamPlayer in audioPlayers.get_children():
		if not audioStreamPlayer.playing:
			audioStreamPlayer.stream = sound
			audioStreamPlayer.play()
			break
