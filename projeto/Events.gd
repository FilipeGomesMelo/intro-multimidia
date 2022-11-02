extends Node

signal player_died
signal dash_started
signal shake_camera
signal charge_changed

var fruits = 0

func add_fruit(amount: int) -> void:
	fruits += amount
	update_fruits()

func reset_fruit(fruits_colleted_on_fase) -> void:
	fruits = fruits - fruits_colleted_on_fase
	update_fruits()

func update_fruits() -> void:
	print(fruits)

