extends CharacterBody3D

enum DrinkState {NO_DRINK, WANTS_DRINK, HAS_DRINK, DISTURBANCE}

var drink_state: DrinkState = DrinkState.NO_DRINK

var drink_want: Drinks.DrinkType = Drinks.DrinkType.NO_MATCH

@export var can_move: bool = false
var is_moving: bool = false

@export var movement_timer: Timer
@export var talking_timer: Timer
@export var invincibility_timer: Timer

@onready var nav: NavigationAgent3D = %NavigationAgent3D

@onready var rng = RandomNumberGenerator.new()

@export var min_silent_duration: float = 1.0
@export var max_silent_duration: float = 7.0
@export var min_talking_duration: float = 1.0
@export var max_talking_duration: float = 7.0

signal drink_gotten(drink_type: Drinks.DrinkType)

var is_pushed: bool = false:
	get:
		return $InvincibilityTimer.time_left > 0

func _ready() -> void:
	rng.randomize()
	var is_woman = rng.randi_range(0, 1) == 0
	
	if is_woman:
		$SpriteOrigin/MainSprite.sprite_frames = preload("res://Entities/frog_woman_sprites.tres")
		$SpriteOrigin/Hand.texture = preload("res://Gfx/WOMAN FINGERS.png")
		$SpriteOrigin/MainSprite/Drink.offset = Vector2(700, 2400)
		$SpriteOrigin/MainSprite/Drink.flip_h = true
		$SpriteOrigin/Hand.position.y += 0.1
		$SpriteOrigin/MainSprite.position.y += 0.1
		$SpriteOrigin/MainSprite/Drink.position.y += 0.1
	else:
		$SpriteOrigin/MainSprite/Drink.offset = Vector2(-1350, 1500)
	
	var flipped = rng.randi_range(0, 1) == 0
	$SpriteOrigin/MainSprite.flip_h = flipped
	$SpriteOrigin/Hand.flip_h = flipped
	
	if flipped:
		$SpriteOrigin/MainSprite.position.x *= -1
		$SpriteOrigin/Hand.position.x *= -1
		$SpriteOrigin/MainSprite/Drink.offset.x *= -1
		$SpriteOrigin/MainSprite/Drink.flip_h = not $SpriteOrigin/MainSprite/Drink.flip_h
		$BubbleRoot/Bubble.flip_h = true
		$BubbleRoot/Bubble.offset.x *= -1
		$BubbleRoot/Sprite3D.offset.x *= -1
	
	# Randomize drink want (cannot be no match)
	while drink_want == Drinks.DrinkType.NO_MATCH:
		drink_want = Drinks.DrinkType.values().pick_random()
	
	if can_move:
		movement_timer.wait_time = rng.randf_range(1.0, 5.0)
		movement_timer.timeout.connect(start_moving)
		nav_setup.call_deferred()
	
	talking_timer.wait_time = rng.randf_range(0.0, max_silent_duration)
	talking_timer.start()

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

func become_disturbance() -> void:
	set_drink_state(DrinkState.DISTURBANCE)

func set_drink_state(new_state: DrinkState) -> void:
	drink_state = new_state
	
	if drink_state == DrinkState.DISTURBANCE:
		$SpriteOrigin/MainSprite/Angry.visible = true
		$TalkingTimer.stop()
		$SpriteOrigin/MainSprite.play("relax_angry")
		$SpriteOrigin/MainSprite.modulate = Color(1.0, 0.8, 0.8)
		$BubbleRoot.visible = false
	else:
		$SpriteOrigin/MainSprite/Angry.visible = false
		$SpriteOrigin/MainSprite.modulate = Color.WHITE
		$TalkingTimer.start()
		
	$SpriteOrigin/MainSprite/Drink.visible = drink_state == DrinkState.HAS_DRINK
	match drink_want:
		Drinks.DrinkType.A:
				$SpriteOrigin/MainSprite/Drink.texture = preload("res://Gfx/Martini.png")
		Drinks.DrinkType.B:
				$SpriteOrigin/MainSprite/Drink.texture = preload("res://Gfx/Rum&Croak.png")
		Drinks.DrinkType.C:
				$SpriteOrigin/MainSprite/Drink.texture = preload("res://Gfx/SwampWater.png")

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
	$BubbleRoot.visible = false
	$CollisionShape3D.disabled = true
	$SpriteOrigin/MainSprite.billboard = BaseMaterial3D.BILLBOARD_DISABLED
	var camera: Camera3D = get_viewport().get_camera_3d()
	$SpriteOrigin.global_rotation_degrees.y = camera.global_rotation_degrees.y
	#$SpriteOrigin.global_rotation_degrees.x = -85.0
	$SpriteAnim.play("Pushed")
	invincibility_timer.timeout.connect(
		func(): 
			$CollisionShape3D.disabled = false
			$SpriteOrigin.global_rotation_degrees.x = 0.0
			$SpriteOrigin/MainSprite.play("relax_neutral")
			$SpriteAnim.play("Raise_Pushed")
			$SpriteAnim.animation_finished.connect(go_to_billboard)
			if drink_state == DrinkState.WANTS_DRINK:
				$BubbleRoot.visible = true
	)
	$SpriteOrigin/Hand.visible = false
	$SpriteOrigin/MainSprite/Drink.visible = false
	$SpriteOrigin/MainSprite.play("relax_angry")
	if drink_state == DrinkState.HAS_DRINK:
		GameManager.remove_score(5.0)
		set_drink_state(DrinkState.NO_DRINK)
	elif drink_state == DrinkState.DISTURBANCE:
		GameManager.add_score(10.0)
		set_drink_state(DrinkState.NO_DRINK)

func go_to_billboard(animation_name):
	$SpriteOrigin/MainSprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
	$SpriteAnim.animation_finished.disconnect(go_to_billboard)

func on_interact(interactor: Node3D) -> void:
	if is_pushed:
		return
	
	if drink_state == DrinkState.HAS_DRINK:
		# make angry face then return
		$SpriteOrigin/MainSprite.play("relax_angry")
		$SpriteOrigin/MainSprite.animation_finished.connect(anger)
		return
	
	if drink_state == DrinkState.DISTURBANCE:
		return
		
	
	var drink_recieved = false
	
	if drink_state == DrinkState.WANTS_DRINK:
	
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
				$SpriteOrigin/MainSprite.play("drink_neutral")
				
				$SpriteOrigin/MainSprite/GoodOrder.visible = true
				await get_tree().create_timer(1).timeout.connect(
					func():
						$SpriteOrigin/MainSprite/GoodOrder.visible = false
				)
				
				get_random_drink()
				$DrinkingTimer.start()
				$DrinkingTimer.timeout.connect( func(): 
					set_drink_state(DrinkState.NO_DRINK)
					$SpriteOrigin/MainSprite.play("relax_neutral")
				)
			
	
	if not drink_recieved:
		$SpriteOrigin/MainSprite.play("relax_angry")
		$SpriteOrigin/MainSprite.animation_finished.connect(anger)
		$SpriteOrigin/MainSprite/WrongOrder.visible = true
		await get_tree().create_timer(1).timeout.connect(
			func():
				$SpriteOrigin/MainSprite/WrongOrder.visible = false
		)
		pass

func anger():
	if $SpriteOrigin/MainSprite.animation == "relax_angry":
		$SpriteOrigin/MainSprite.play("relax_neutral")
	$SpriteOrigin/MainSprite.animation_finished.disconnect(anger)

func get_random_drink():
	drink_want = Drinks.DrinkType.values().pick_random()
	while drink_want == Drinks.DrinkType.NO_MATCH:
		drink_want = Drinks.DrinkType.values().pick_random()

func want_drink():
	drink_state = DrinkState.WANTS_DRINK
	$BubbleRoot.visible = true
	match drink_want:
		Drinks.DrinkType.A:
			$BubbleRoot/Sprite3D.texture = preload("res://Gfx/Martini.png")
		Drinks.DrinkType.B:
			$BubbleRoot/Sprite3D.texture = preload("res://Gfx/Rum&Croak_center.png")
		Drinks.DrinkType.C:
			$BubbleRoot/Sprite3D.texture = preload("res://Gfx/SwampWater.png")
	#$BubbleRoot/Label3D.text = "I want to drink " + str( Drinks.DrinkType.keys()[drink_want])
	return drink_want


func _on_main_sprite_animation_changed() -> void:
	$SpriteOrigin/Hand.visible = ($SpriteOrigin/MainSprite.animation as StringName).containsn("drink")


func _on_talking_timer_timeout() -> void:
	
	if ($SpriteOrigin/MainSprite.animation as StringName).containsn("talk"):
		talking_timer.wait_time = rng.randf_range(min_silent_duration, max_silent_duration)
		if ($SpriteOrigin/MainSprite.animation as StringName).containsn("drink"):
			$SpriteOrigin/MainSprite.play("drink_neutral")
		if ($SpriteOrigin/MainSprite.animation as StringName).containsn("relax"):
			$SpriteOrigin/MainSprite.play("relax_neutral")
	elif ($SpriteOrigin/MainSprite.animation as StringName).containsn("neutral"):
		talking_timer.wait_time = rng.randf_range(min_talking_duration, max_talking_duration)
		if ($SpriteOrigin/MainSprite.animation as StringName).containsn("drink"):
			$SpriteOrigin/MainSprite.play("drink_talk")
		else:
			$SpriteOrigin/MainSprite.play("relax_talk")

	
		
