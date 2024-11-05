extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$VBoxContainer/Restart.grab_focus()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_restart_button_up() -> void:
	get_tree().change_scene_to_file("res://main_level.tscn")
	queue_free()


func _on_main_menu_button_up() -> void:
	get_tree().change_scene_to_file("res://Menus/main_menu.tscn")
	queue_free()
