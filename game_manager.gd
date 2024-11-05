extends Node

var score: float = 0.0

@export var game_timer: Timer

# List of all frogs in the scene
var frogs: Array[Node]

var is_right_handed = true

signal game_ended
signal score_changed(new_score: float)

var tray_scene: Node3D

func _ready() -> void:
	game_timer.timeout.connect(load_end_menu)

func remove_score(value: float) -> void:
	set_score(score - value)

func add_score(value: float) -> void:
	set_score(score + value)

func set_score(value: float) -> void:
	if score != value:
		score = value
		score_changed.emit(score)

func get_score() -> float:
	return score

func start_game():
	# load in all frogs in scene into list
	frogs = find_nodes_with_script(get_tree().root, load("res://Entities/frog.gd"))
	tray_scene = find_nodes_with_script(get_tree().root, load("res://tray_scene.gd"))[0]
	for frog in frogs:
		frog.drink_gotten.connect(tray_scene.remove_drink)

func start_timer():
	game_timer.start()

func on_game_end() -> void:
	game_ended.emit()
	load_end_menu()

func load_end_menu() -> void:
	pass
	
func make_disturbance() -> void:
	# Loop through all frogs, find one that is not looking for an order
	for frog in frogs:
		var random_frog = frogs.pick_random()
		if random_frog.drink_state != 1:
			random_frog.become_disturbance()
			break
	pass

func make_order_request() -> void:
	# Loop through all frogs, find one that is either neutral or has a drink 
	for frog in frogs:
		var random_frog = frogs.pick_random()
		if random_frog.drink_state == 0:
			random_frog.want_drink()
			break

func find_nodes_with_script(root: Node, script: Script) -> Array[Node]:
	var nodes_with_script: Array[Node] = []
	
	if root.get_script() == script:
		nodes_with_script.append(root)
	
	for child in root.get_children():
		nodes_with_script += find_nodes_with_script(child, script)
	
	return nodes_with_script


func _on_drink_request_timer_timeout() -> void:
	make_order_request()


func _on_disturbance_timer_timeout() -> void:
	make_disturbance()
