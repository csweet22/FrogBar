extends RigidBody3D

var drink_type: Drinks.DrinkType

signal fell(drink: RigidBody3D)

var to_be_freed: bool = false

func set_up(drink_type: Drinks.DrinkType):
	self.drink_type = drink_type
	match self.drink_type:
		Drinks.DrinkType.A:
			$Sprite3D.texture = preload("res://Gfx/Martini.png")
		Drinks.DrinkType.B:
			$Sprite3D.texture = preload("res://Gfx/Rum&Croak_center.png")
		Drinks.DrinkType.C:
			$Sprite3D.texture = preload("res://Gfx/SwampWater.png")

func _process(delta: float) -> void:
	if position.y < -1.0 and not to_be_freed:
		to_be_freed = true
		print(name + " has fallen.")
		fell.emit(self)
