extends Node

var score: float = 0.0

@export var game_timer: Timer

# List of all frogs in the scene
var frogs: Array[Node]

var is_right_handed = true

signal game_ended
signal score_changed(new_score: float)

var tray_scene: Node3D

@export var interact_spawn_drink: Label

var active_order_count: int = 0:
	set(value):
		active_order_count = value
		print("active_order_count: " + str(active_order_count))
var max_active_order_count: int = 5

var player: Node3D
var hud: Control

var first_drink_delivered: bool = false:
	set(value):
		if value and not first_drink_delivered:
			make_disturbance()
		first_drink_delivered = value
var first_disturbance_ended: bool = false:
	set(value):
		if value and not first_disturbance_ended:
			start_timer()
		first_disturbance_ended = value

func _ready() -> void:
	game_timer.timeout.connect(on_game_end)
	$ribbit/RibbitTimer.timeout.connect(
		func():
			$ribbit/RibbitTimer.wait_time = RandomNumberGenerator.new().randf_range(2.0, 10.0)
			$ribbit.play()
	)

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
	first_drink_delivered = false
	first_disturbance_ended = false
	active_order_count = 0
	set_score(0)
	# load in all frogs in scene into list
	frogs = find_nodes_with_script(get_tree().root, load("res://Entities/frog.gd"))
	tray_scene = find_nodes_with_script(get_tree().root, load("res://tray_scene.gd"))[0]
	player = find_nodes_with_script(get_tree().root, load("res://Entities/player.gd"))[0]
	hud = find_nodes_with_script(get_tree().root, load("res://Menus/hud_menu.gd"))[0]
	for frog in frogs:
		frog.drink_gotten.connect(tray_scene.remove_drink)
		frog.drink_gotten.connect( 
			func(drink_scene):
				first_drink_delivered = true
				tray_scene.spawn_money(2)
				$chaching.play()
		)
	get_tree().create_timer(1).timeout.connect(make_order_request)

func start_timer():
	game_timer.start(0.0)
	$DrinkRequestTimer.start(0.0)
	$DisturbanceTimer.start(0.0)

func on_game_end() -> void:
	tray_scene.rotation_degrees.z = 0
	tray_scene.can_tip = false
	game_ended.emit()
	tray_scene.spawn_money(20)
	player.movement_disabled = true
	stop_timers()
	load_end_menu()

func stop_timers():
	$GameTimer.stop()
	$DrinkRequestTimer.stop()
	$DisturbanceTimer.stop()
	

func load_end_menu() -> void:
	get_tree().root.add_child(preload("res://Menus/end_menu.tscn").instantiate())
	
func make_disturbance() -> void:
	var already_disturbed = false
	for frog in frogs:
		if frog.drink_state == 3:
			already_disturbed = true
			break
	
	if already_disturbed:
		return
	
	# Loop through all frogs, find one that is not looking for an order
	for frog in frogs:
		var random_frog = frogs.pick_random()
		if random_frog.drink_state == 0 and not random_frog.is_pushed:
			random_frog.become_disturbance()
			break
	pass

func make_order_request() -> void:
	if active_order_count >= max_active_order_count:
		return
	# Loop through all frogs, find one that is either neutral or has a drink 
	for frog in frogs:
		var random_frog = frogs.pick_random()
		if random_frog.drink_state == 0 && not random_frog.is_pushed:
			var request: Drinks.DrinkType = random_frog.want_drink()
			break

func find_nodes_with_script(root: Node, script: Script) -> Array[Node]:
	var nodes_with_script: Array[Node] = []
	
	if root.get_script() == script:
		nodes_with_script.append(root)
	
	for child in root.get_children():
		nodes_with_script += find_nodes_with_script(child, script)
	
	return nodes_with_script

func glass_shatter(drink_type: Drinks.DrinkType):
	# after 1.0 seconds, play the appropriate glass shatter sound
	pass

func _on_drink_request_timer_timeout() -> void:
	make_order_request()


func _on_disturbance_timer_timeout() -> void:
	make_disturbance()

func clink_glass():
	if RandomNumberGenerator.new().randi_range(0, 1) == 0:
		if not $ClinkA.playing:
			$ClinkA.play()
	else:
		if not $ClinkB.playing:
			$ClinkB.play()

func break_glass():
	if RandomNumberGenerator.new().randi_range(0, 1) == 0:
		if not $BreakA.playing:
			$BreakA.play()
	else:
		if not $BreakB.playing:
			$BreakB.play()
