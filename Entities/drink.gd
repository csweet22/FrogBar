extends RigidBody3D

var drink_type: Drinks.DrinkType

signal fell(drink_type: Drinks.DrinkType)

func set_up(drink_type: Drinks.DrinkType):
	self.drink_type = drink_type

func _process(delta: float) -> void:
	if position.y < -1.0:
		fell.emit(drink_type)
		queue_free()
