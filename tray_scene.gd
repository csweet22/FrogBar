extends Node3D

@export var offset: Vector3

@export var tilt_speed: float = 2.0

var push_tween: Tween

@onready var tray_cam = $SubViewportContainer/SubViewport/Camera3D

var default_global_position: Vector3

@export var tipping_speed: float = 0.2

@onready var drink_scene: PackedScene = preload("res://Entities/drink.tscn")
@onready var money_scene: PackedScene = preload("res://Entities/money_scene.tscn")

var drinks: Array[RigidBody3D]

var current_tilt_delta = 0.0

@export var min_tilt_time: float = 3.0
@export var max_tilt_time: float = 8.0
var tilting_right: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	current_tilt_delta = tipping_speed / 2
	if not GameManager.is_right_handed:
		offset.x *= -1
		$SubViewportContainer.position.x *= -1
	tray_cam.global_position = global_position + offset
	default_global_position = tray_cam.global_position



func _process(delta: float) -> void:
	if Input.is_action_pressed("tray_left"):
		tilt_tray(tilt_speed * delta)
	if Input.is_action_pressed("tray_right"):
		tilt_tray(-tilt_speed * delta)
	
	if tilting_right:
		current_tilt_delta += tipping_speed * delta
	else:
		current_tilt_delta -= tipping_speed * delta
	
	current_tilt_delta = clamp(current_tilt_delta, -tipping_speed, tipping_speed)
	
	tilt_tray(delta * current_tilt_delta)
	
		
		
	#if $CharacterBody3D.rotation_degrees.z > 0:
		#$CharacterBody3D.rotate_z(delta * tipping_speed)
	#else:
		#$CharacterBody3D.rotate_z(-delta * tipping_speed)

func tilt_tray(amount: float) -> void:
		$CharacterBody3D.rotate_z(amount)
		
		$CharacterBody3D.rotation_degrees.z = clampf($CharacterBody3D.rotation_degrees.z, -80, 80)

func _on_player_rotated(degrees: float) -> void:
	pass
	#tilt_tray(degrees / 10)


# move camera to and from (0.0, 0.0, 1.5)
func on_push():
	if push_tween:
		push_tween.kill()
	push_tween = get_tree().create_tween()
	push_tween.tween_property(tray_cam, "global_position", global_position + Vector3(0.0, 0.0, 2), 0.07)
	push_tween.set_ease(Tween.EASE_OUT)
	push_tween.set_trans(Tween.TRANS_QUAD)
	push_tween.chain().tween_property(tray_cam, "global_position", default_global_position, 0.1)
	


func _on_player_pushed() -> void:
	on_push()

func remove_drink(drink: RigidBody3D):
	print("Trying to delete " + drink.name)
	drinks.erase(drink)
	drink.queue_free()

func spawn_money(count: float):
	#var instance: Node3D = money_scene.instantiate()
	#instance.position = Vector3(-0.3 * (1.0 if GameManager.is_right_handed else -1.0), 1.5, 0.0)
	#add_child(instance)
	for i in range(0, count):
		await get_tree().create_timer(0.5).timeout.connect(
			func():
				var instance: Node3D = money_scene.instantiate()
				instance.position = Vector3(-0.3 * (1.0 if GameManager.is_right_handed else -1.0), 1.5, 0.0)
				add_child(instance)
		)

func _on_bar_spawner_spawn_drink(drink_type: Drinks.DrinkType) -> void:
	var instance: Node3D = drink_scene.instantiate()
	instance.position = Vector3(-0.3 * (1.0 if GameManager.is_right_handed else -1.0), 1.0, 0.0)
	instance.set_up(drink_type)
	drinks.append(instance)
	add_child(instance)
	instance.fell.connect(remove_drink)
	print("Spawned " + instance.name)


func _on_tilt_timer_timeout() -> void:
	tilting_right = not tilting_right
	$TiltTimer.wait_time = RandomNumberGenerator.new().randf_range(min_tilt_time, max_tilt_time)
