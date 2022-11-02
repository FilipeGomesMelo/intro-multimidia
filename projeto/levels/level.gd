extends Node2D

const PlayerScene = preload("res://Player/Player.tscn")

var player_spawn_location = Vector2.ZERO

onready var camera: = $Camera2D
onready var player: = $Player
onready var timer: = $Timer
onready var HUD: = $HUD

func _ready():
	VisualServer.set_default_clear_color(Color.lightblue)
	player.connect_camera(camera)
	player_spawn_location = player.global_position
	Events.connect("player_died", self, "_on_player_died")
	Events.connect("dash_started", self, "_on_dash_started")
	Events.connect("shake_camera", self, "_on_shake_camera")
	Events.connect("charge_changed", self, "_on_charge_changed")

func _on_player_died():
	timer.start(0.5)
	yield(timer, "timeout")
	get_tree().reload_current_scene()


func _on_dash_started():
	camera.shake(0.2, 1.25)


func _on_shake_camera(shake_time, shake_amount):
	camera.shake(shake_time, shake_amount)


func _on_charge_changed():
	HUD.update_charge(player.action_count, player.ACTION_COUNT)
