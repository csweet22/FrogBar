extends CharacterBody3D

enum DrinkState {NO_DRINK, WANTS_DRINK, HAS_DRINK}

var drink_state: DrinkState = DrinkState.NO_DRINK

var drink_want: Drinks.DrinkType = Drinks.DrinkType.A

@export var can_move: bool = false

@export var movement_timer: Timer
@export var talking_timer: Timer
@export var bozoing_timer: Timer

func _ready() -> void:
	# Randomize drink state?
	movement_timer.timeout.connect(start_moving)
	# connect arrive at target to stop_moving()

func start_talking() -> void:
	pass

func stop_talking() -> void:
	pass

func become_disturbance() -> void:
	pass

func set_drink_state(new_state: DrinkState) -> void:
	drink_state = new_state

func start_moving() -> void:
	# set path target + move to path
	# stop timer
	pass

func stop_moving() -> void:
	# set new random stay still duration
	# restart stay-still timer
	pass

func on_pushed() -> void:
	bozoing_timer.start(0.0)
	if drink_state == DrinkState.HAS_DRINK:
		GameManager.remove_score(5.0)
		pass

func on_interact(tray_drinks: Array[Drinks.DrinkType]) -> Drinks.DrinkType:
	# Check if tray contains drink they want
	# If so, change state and drink want.
	for drink: Drinks.DrinkType in tray_drinks:
		if drink == drink_want:
			set_drink_state(DrinkState.HAS_DRINK)
			return Drinks.DrinkType
	
	# Do the "nuh-uh"
	
	return Drinks.NO_MATCH
