extends RigidBody3D

var drink_type: Drinks.DrinkType

signal fell(drink: RigidBody3D)

var to_be_freed: bool = false

func set_up(drink_type: Drinks.DrinkType):
	max_contacts_reported = 1
	$Martini.disabled = true
	$Rum.disabled = true
	$SwampWater.disabled = true
	self.drink_type = drink_type
	match self.drink_type:
		Drinks.DrinkType.A:
			$Sprite3D.texture = preload("res://Gfx/Martini.png")
			$Martini.disabled = false
		Drinks.DrinkType.B:
			$Sprite3D.texture = preload("res://Gfx/Rum&Croak_center.png")
			$Rum.disabled = false
		Drinks.DrinkType.C:
			$Sprite3D.texture = preload("res://Gfx/SwampWater.png")
			$SwampWater.disabled = false

func _process(delta: float) -> void:
	if position.y < -1.0 and not to_be_freed:
		to_be_freed = true
		print(name + " has fallen.")
		fell.emit(self)
		await get_tree().create_timer(0.1).timeout.connect(GameManager.break_glass)


func _on_body_entered(body: Node) -> void:
	print("BODY ENTERED")
	if $Clink.playing:
		return
	
	$Clink.pitch_scale = RandomNumberGenerator.new().randf_range(0.9, 1.1)
	
	if RandomNumberGenerator.new().randi_range(0, 1) == 0:
		$Clink.stream = preload("res://Sounds/clink_A.mp3")
	else:
		$Clink.stream = preload("res://Sounds/clink_B.mp3")
	$Clink.play()
