extends CanvasLayer

signal restart

@onready var final_score_label := $Panel/VBoxContainer/FinalScoreLabel

func _ready():
	add_to_group("game_over")

func set_score(score: int):
	final_score_label.text = "Final Score: %d" % score

func _on_restart_pressed():
	restart.emit()
