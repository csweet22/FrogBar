extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@export var rotation_speed = 2.0

var can_push: bool = true

var interactables: Array[Node3D]

signal rotated(degrees: float)
signal pushed()

var movement_disabled = false

var can_interact: bool = true

func _input(event):
	if event.get_action_strength("interact") > 0.6:
		if can_interact:
			can_interact = false
			interact()
	if event.get_action_strength("interact") < 0.4:
		can_interact = true
		

var left_just_pressed: bool = false
var right_just_pressed: bool = false

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("main_menu"):
		get_tree().change_scene_to_file("res://Menus/main_menu.tscn")
		GameManager.stop_timers()
	
	if Input.is_action_just_pressed("tray_left"):
		if right_just_pressed:
			push()
			right_just_pressed = false
			left_just_pressed = false
			return
		
		if left_just_pressed:
			return
		
		left_just_pressed = true
		get_tree().create_timer(0.1).timeout.connect(
			func():
				left_just_pressed = false
		)
	
	if Input.is_action_just_pressed("tray_right"):
		if left_just_pressed:
			push()
			right_just_pressed = false
			left_just_pressed = false
			return
		
		if right_just_pressed:
			return
		
		right_just_pressed = true
		get_tree().create_timer(0.1).timeout.connect(
			func():
				right_just_pressed = false
		)
	
	#if Input.is_action_pressed("tray_left") and Input.is_action_pressed("tray_right") and can_push:
		#push()
	
	if Input.is_action_just_released("tray_left") || Input.is_action_just_released("tray_right"):
		can_push = true

func _physics_process(delta: float) -> void:
	if movement_disabled:
		return
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	var input_dir := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var direction := (transform.basis * Vector3(0, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	var rotation_amount: float = -input_dir.x * rotation_speed * delta
	
	rotate_y(rotation_amount)
	rotated.emit(rotation_amount)

	move_and_slide()

func push():
	# Check what frogs are in front in area2D, call their on_pushed()
	can_push = false
	
	for body in $PushArea.get_overlapping_bodies():
		if body.has_method("on_pushed"):
			body.on_pushed()
	
	pushed.emit()

func interact():
	# get closest interactable from the list
	
	for interactable in interactables:
		interactable.on_interact(self)
	return


func _on_interaction_area_area_entered(area: Area3D) -> void:
	if area.owner.has_method("on_interact"):
		interactables.append(area.owner)
	#print(interactables)


func _on_interaction_area_area_exited(area: Area3D) -> void:
	if area.owner.has_method("on_interact"):
		interactables.erase(area.owner)
	#print(interactables)
