# ScoreUI.gd - Attach this to a Control node or CanvasLayer
extends Control

@onready var score_label: Label = $ScoreLabel
var current_score: int = 0
var game_manager = get_tree().get_first_node_in_group("game_manager") 
func _ready():
	print("ScoreUI _ready() called!")
	
	# Connect to GameManager's score signal
	var game_manager = get_node_or_null("/root/GameManager")
	print("ScoreUI - Trying to find GameManager at /root/GameManager")
	
	if game_manager:
		print("ScoreUI - GameManager found: true")
		if game_manager.has_signal("score_changed"):
			print("ScoreUI - score_changed signal exists: true")
			game_manager.score_changed.connect(_on_score_changed)
			print("Connected to score_changed signal")
		else:
			print("ScoreUI - score_changed signal exists: false")
	else:
		print("ScoreUI - GameManager found: false")
	
	# Debug the score label
	if score_label:
		print("ScoreUI - Score Label found: true")
	else:
		print("ScoreUI - Score Label found: false")
	
	update_score_display()
	
	update_score_display()

func _on_score_changed(new_score: int):
	current_score = new_score
	update_score_display()

func update_score_display():
	if score_label:
		score_label.text = "Score: " + str(current_score)

func add_bonus_points(points: int, reason: String = ""):
	# Visual feedback for bonus points
	current_score += points
	update_score_display()
	
	if reason != "":
		show_bonus_text(points, reason)

func show_bonus_text(points: int, reason: String):
	# Create floating bonus text
	var bonus_label = Label.new()
	bonus_label.text = "+" + str(points) + " " + reason + "!"
	bonus_label.modulate = Color.YELLOW
	bonus_label.position = Vector2(100, 50)
	add_child(bonus_label)
	
	# Animate the bonus text
	var tween = create_tween()
	tween.parallel().tween_property(bonus_label, "position", bonus_label.position + Vector2(0, -50), 1.0)
	tween.parallel().tween_property(bonus_label, "modulate:a", 0.0, 1.0)
	tween.tween_callback(bonus_label.queue_free)
