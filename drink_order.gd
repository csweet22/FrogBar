extends MarginContainer

var drink_type: Drinks.DrinkType

func activate(texture: Texture2D, type: Drinks.DrinkType):
	drink_type = type
	$DrinkImage.texture = texture

func deactivate():
	queue_free()
