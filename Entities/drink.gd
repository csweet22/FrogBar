extends RigidBody3D

var drink_type: Drinks.DrinkType

signal fell(drink: RigidBody3D)

var to_be_freed: bool = false

func set_up(drink_type: Drinks.DrinkType):
	self.drink_type = drink_type

func _process(delta: float) -> void:
	if position.y < -1.0 and not to_be_freed:
		to_be_freed = true
		print(name + " has fallen.")
		fell.emit(self)
