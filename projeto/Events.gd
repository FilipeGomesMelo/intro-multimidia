extends Node

signal player_died

var fruits = 0

func add_fruit(amount: int) -> void:
	fruits += amount
	update_fruits()

func reset_fruit() -> void:
	fruits = 0
	update_fruits()

func update_fruits() -> void:
	get_node("/root/test_level/TileMap/FruitsLayer/CountFruits").text = "Fruits: " + str(fruits)
