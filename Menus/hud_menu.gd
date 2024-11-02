extends Control

@export var score_label: Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.score_changed.connect(on_score_changed)

func on_score_changed(score: float):
	score_label.text = "$" + ("%.2f" % score)
