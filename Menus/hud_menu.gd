extends Control

@export var score_label: Label

var pointer: int = 0
@export var drinks: Array[Control]
var free_spots: Array[int] = [0, 1, 2, 3, 4]

var display_score: float = 0.0:
	get:
		return display_score
	set(value):
		display_score = value
		score_label.text = "$" + ("%.2f" % display_score) 
var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.score_changed.connect(on_score_changed)

func _process(delta: float) -> void:
	$Main/VBoxContainer/TimeRemaining.text = "Time Remaining: " + "%02d:%02d" % [GameManager.game_timer.time_left / 60, fmod(GameManager.game_timer.time_left, 60)]

func add_drink(type: Drinks.DrinkType):
	var index = free_spots.pick_random()
	free_spots.erase(index)
	
	match type:
		Drinks.DrinkType.A:
			drinks[index].activate(preload("res://Gfx/Martini.png"), Drinks.DrinkType.A)
		Drinks.DrinkType.B:
			drinks[index].activate(preload("res://Gfx/Rum&Croak_center.png"), Drinks.DrinkType.B)
		Drinks.DrinkType.C:
			drinks[index].activate(preload("res://Gfx/SwampWater.png"), Drinks.DrinkType.C)

func remove_drink(type: Drinks.DrinkType):
	var index = 0;
	for drink in drinks:
		if drink.drink_type == type:
			free_spots.append(index)
			drink.deactivate()
			break
		index += 1

func on_score_changed(score: float):
	if tween:
		tween.kill() # Abort the previous animation.
	tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "display_score", score, 1.0)
