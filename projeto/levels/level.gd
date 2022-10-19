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
	Events.connect("dash_started", self, "_on_dash_started")

func _on_player_died():
	for child in get_children():
		if child is Player:
			child.queue_free()
	timer.start(0.5)
	yield(timer, "timeout")
	var player = PlayerScene.instance()
	player.global_position = player_spawn_location
	add_child(player)
	player.connect_camera(camera)

func _on_dash_started():
	camera.shake(0.125, 1)
