extends CharacterBody3D

enum DrinkState {NO_DRINK, WANTS_DRINK, HAS_DRINK}

var drink_state: DrinkState = DrinkState.NO_DRINK

var drink_want: Drinks.DrinkType = Drinks.DrinkType.NO_MATCH

@export var can_move: bool = false
var is_moving: bool = false

@export var movement_timer: Timer
@export var talking_timer: Timer
@export var invincibility_timer: Timer

@onready var nav: NavigationAgent3D = %NavigationAgent3D

@onready var rng = RandomNumberGenerator.new()

signal drink_gotten(drink_type: Drinks.DrinkType)

func _ready() -> void:
	rng.randomize()
	$SpriteOrigin/MainSprite.flip_h = rng.randi_range(0, 1) == 0
	if rng.randi_range(0, 1) == 0:
		$SpriteOrigin/MainSprite.modulate = Color.AQUA
	
	# Randomize drink want (cannot be no match)
	while drink_want == Drinks.DrinkType.NO_MATCH:
		drink_want = Drinks.DrinkType.values().pick_random()
	
	if can_move:
		movement_timer.wait_time = rng.randf_range(1.0, 5.0)
		movement_timer.timeout.connect(start_moving)
		nav_setup.call_deferred()

func nav_setup():
	nav.path_desired_distance = 0.1
	nav.target_desired_distance = 0.1
	
	await get_tree().physics_frame
	
	nav.navigation_finished.connect(stop_moving)

func set_new_target(): 
	var target: Vector3 = Vector3( rng.randf_range(-3.0, 3.0), 0.0, rng.randf_range(-3.0, 3.0))
	nav.set_target_position( target )

func _physics_process(delta: float) -> void:
	
	if not is_moving or invincibility_timer.time_left > 0.0:
		return
	
	var current_agent_position: Vector3 = global_position
	var next_path_position: Vector3 = nav.get_next_path_position()

	velocity = current_agent_position.direction_to(next_path_position) * 1.0
	move_and_slide()

func start_talking() -> void:
	pass

func stop_talking() -> void:
	pass

func become_disturbance() -> void:
	print(name + " wants to become disturbance.")

func set_drink_state(new_state: DrinkState) -> void:
	drink_state = new_state

func start_moving() -> void:
	is_moving = true
	set_new_target()
	pass

func stop_moving() -> void:
	is_moving = false
	# set new random stay still duration
	movement_timer.wait_time = rng.randf_range(1.0, 5.0)
	# restart stay-still timer
	movement_timer.start()
	pass

func on_pushed() -> void:
	invincibility_timer.start(0.0)
	$CollisionShape3D.disabled = true
	$SpriteOrigin/MainSprite.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	var camera: Camera3D = get_viewport().get_camera_3d()
	$SpriteOrigin.global_rotation_degrees.y = camera.global_rotation_degrees.y
	$SpriteOrigin.global_rotation_degrees.x = -85.0
	invincibility_timer.timeout.connect(
		func(): 
			$CollisionShape3D.disabled = false
			$SpriteOrigin/MainSprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
			$SpriteOrigin.global_rotation_degrees.x = 0.0
	)
	if drink_state == DrinkState.HAS_DRINK:
		GameManager.remove_score(5.0)
		drink_state = DrinkState.NO_DRINK

func on_interact(interactor: Node3D) -> void:
	var drink_recieved = false
	
	# Check if tray contains drink they want
	# If so, change state and drink want.
	for drink in GameManager.tray_scene.drinks:
		if drink.drink_type == drink_want:
			GameManager.add_score(5.0)
			set_drink_state(DrinkState.HAS_DRINK)
			drink_recieved = true
			$BubbleRoot.visible = false
			# remove drink from tray with signal
			drink_gotten.emit(drink)
			get_random_drink()
			$DrinkingTimer.start()
			$DrinkingTimer.timeout.connect( func(): 
				set_drink_state(DrinkState.NO_DRINK)
			)
			
	
	if not drink_recieved:
		# Do the "nuh-uh"
		pass

func get_random_drink():
	drink_want = Drinks.DrinkType.values().pick_random()
	while drink_want == Drinks.DrinkType.NO_MATCH:
		drink_want = Drinks.DrinkType.values().pick_random()

func want_drink():
	drink_state = DrinkState.WANTS_DRINK
	$BubbleRoot.visible = true
	$BubbleRoot/Label3D.text = "I want to drink " + str( Drinks.DrinkType.keys()[drink_want])
