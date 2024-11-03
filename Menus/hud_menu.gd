extends Control

@export var score_label: Label

var display_score: float = 0.0
var tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.score_changed.connect(on_score_changed)

func on_score_changed(score: float):
	if tween:
		tween.kill() # Abort the previous animation.
	tween = create_tween()
	tween.set_trans(Tween.TRANS_QUAD)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_method(update_label, display_score, score, 1.0)
	tween.tween_property(self, "display_score", score, 1.0)

func update_label(new_score: float): 
	score_label.text = "$" + ("%.2f" % new_score) 
