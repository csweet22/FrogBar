extends Control

@export var score_label: Label

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

func on_score_changed(score: float):
	if tween:
		tween.kill() # Abort the previous animation.
	tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "display_score", score, 1.0)
