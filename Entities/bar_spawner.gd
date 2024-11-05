extends Node3D

signal spawn_drink(type: Drinks.DrinkType)

@export var drink_type: Drinks.DrinkType = Drinks.DrinkType.A

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func on_interact(body: CharacterBody3D) -> void:
	spawn_drink.emit(drink_type)
