extends MarginContainer

var drink_type: Drinks.DrinkType

func activate(texture: Texture2D, type: Drinks.DrinkType):
	print("Activated.")
	drink_type = type
	$DrinkImage.texture = texture
	visible = true

func deactivate():
	print("Deactivated.")
	visible = false
	
