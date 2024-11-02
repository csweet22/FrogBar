extends Node

var score: float = 0.0

@export var game_timer: Timer

# List of all frogs in the scene
var frogs

signal game_ended
signal score_changed(new_score: float)

func _ready() -> void:
	# load in all frogs in scene into list
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

func on_game_end() -> void:
	game_ended.emit()
	load_end_menu()

func load_end_menu() -> void:
	pass
	
func make_disturbance() -> void:
	# Loop through all frogs, find one that is not looking for an order
	pass

func make_order_request() -> void:
	# Loop through all frogs, find one that is either neutral or has a drink 
	pass
