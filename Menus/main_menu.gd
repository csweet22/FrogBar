extends Control

func _ready() -> void:
	$VBoxContainer/StartButton.grab_focus()

func _on_start_button_button_up() -> void:
	GameManager.is_right_handed = $VBoxContainer/Handedness.get_selected() == 0
	print("is_right_handed: " + str(GameManager.is_right_handed))
	get_tree().change_scene_to_file("res://main_level.tscn")
