extends RigidBody3D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if RandomNumberGenerator.new().randi_range(0, 1) == 0:
		$browncoin.visible = true
	else:
		$graycoin.visible = true

func _on_visible_on_screen_notifier_3d_screen_exited() -> void:
	queue_free()
