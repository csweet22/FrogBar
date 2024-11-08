extends Node3D

signal spawn_drink(type: Drinks.DrinkType)

@export var drink_type: Drinks.DrinkType = Drinks.DrinkType.A

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func on_interact(body: CharacterBody3D) -> void:
	spawn_drink.emit(drink_type)


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.is_in_group("player"):
		GameManager.tray_scene.show_preview(drink_type)


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.is_in_group("player"):
		GameManager.tray_scene.hide_preview()
