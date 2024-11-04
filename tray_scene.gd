extends Node3D

@export var offset: Vector3

@export var tilt_speed: float = 1.0

var push_tween: Tween

@onready var tray_cam = $SubViewportContainer/SubViewport/Camera3D

var default_global_position: Vector3

@export var tipping_speed: float = 0.05

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	tray_cam.global_position = global_position + offset
	default_global_position = tray_cam.global_position

func _process(delta: float) -> void:
	if Input.is_action_pressed("tray_left"):
		tilt_tray(tilt_speed * delta)
	if Input.is_action_pressed("tray_right"):
		tilt_tray(-tilt_speed * delta)
	
	if $CharacterBody3D.rotation_degrees.z > 0:
		$CharacterBody3D.rotate_z(delta * tipping_speed)
	else:
		$CharacterBody3D.rotate_z(-delta * tipping_speed)

func tilt_tray(amount: float) -> void:
		$CharacterBody3D.rotate_z(amount)
		
		$CharacterBody3D.rotation_degrees.z = clampf($CharacterBody3D.rotation_degrees.z, -80, 80)

func _on_player_rotated(degrees: float) -> void:
	tilt_tray(degrees / 10)


# move camera to and from (0.0, 0.0, 1.5)
func on_push():
	if push_tween:
		push_tween.kill()
	push_tween = get_tree().create_tween()
	push_tween.tween_property(tray_cam, "global_position", global_position + Vector3(0.0, 0.4, 1.3), 0.07)
	push_tween.set_ease(Tween.EASE_OUT)
	push_tween.set_trans(Tween.TRANS_QUAD)
	push_tween.chain().tween_property(tray_cam, "global_position", default_global_position, 0.1)
	


func _on_player_pushed() -> void:
	on_push()
