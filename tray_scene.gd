extends Node3D

@export var offset: Vector3

@export var tilt_speed: float = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$SubViewportContainer/SubViewport/Camera3D.global_position = $".".global_position + offset

func _process(delta: float) -> void:
	if Input.is_action_pressed("tray_left"):
		tilt_tray(tilt_speed * delta)
	if Input.is_action_pressed("tray_right"):
		tilt_tray(-tilt_speed * delta)

func tilt_tray(amount: float) -> void:
		$CharacterBody3D.rotate_z(amount)

func _on_player_rotated(degrees: float) -> void:
	tilt_tray(degrees / 10)
