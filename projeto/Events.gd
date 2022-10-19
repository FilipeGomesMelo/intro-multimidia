extends Node

signal player_died
signal dash_started

var fruits = 0

func add_fruit(amount: int) -> void:
	fruits += amount
	update_fruits()

func reset_fruit() -> void:
	fruits = 0
	update_fruits()

func update_fruits() -> void:
	print(fruits)
