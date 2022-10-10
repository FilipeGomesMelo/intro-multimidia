extends Node2D

const PlayerScene = preload("res://Player/Player.tscn")

var player_spawn_location = Vector2.ZERO

onready var camera: = $Camera2D
onready var player: = $Player
onready var timer: = $Timer

func _ready():
	VisualServer.set_default_clear_color(Color.lightblue)
	player.connect_camera(camera)
	player_spawn_location = player.global_position
	Events.connect("player_died", self, "_on_player_died")

func _on_player_died():
	timer.start(0.25)
	yield(timer, "timeout")
	var player = PlayerScene.instance()
	player.global_position = player_spawn_location
	add_child(player)
	player.connect_camera(camera)