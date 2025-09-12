# ScoreUI.gd - Attach this to a Control node or CanvasLayer
extends Control

var score_label: Label  # Remove @onready
var current_score: int = 0

func _ready():
	print("ScoreUI _ready() called!")
	
	# Wait a frame to ensure scene tree is ready
	await get_tree().process_frame
	
	# Now find the score label
	score_label = get_node_or_null("ScoreLabel")
	if score_label:
		print("ScoreUI - Score Label found: true")
	else:
		print("ScoreUI - Score Label found: false")
		# Try find_child as backup
		score_label = find_child("ScoreLabel", true, false)
		if score_label:
			print("ScoreUI - Score Label found with find_child: true")
		else:
			print("ScoreUI - Score Label found with find_child: false")
	
	# Connect to GameManager
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		print("ScoreUI - GameManager found: true")
		game_manager.score_changed.connect(_on_score_changed)
		print("Connected to score_changed signal")
	else:
		print("ScoreUI - GameManager found: false")
	
	update_score_display()

func _on_score_changed(new_score: int):
	current_score = new_score
	update_score_display()

func update_score_display():
	print("update_score_display() called, current_score:", current_score)
	if score_label:
		score_label.text = "Score: " + str(current_score)
		print("Score label updated to:", score_label.text)
	else:
		print("ERROR: score_label is null!")

# Keep your other functions as they were...
func add_bonus_points(points: int, reason: String = ""):
	current_score += points
	update_score_display()
	
	if reason != "":
		show_bonus_text(points, reason)

func show_bonus_text(points: int, reason: String):
	var bonus_label = Label.new()
	bonus_label.text = "+" + str(points) + " " + reason + "!"
	bonus_label.modulate = Color.YELLOW
	bonus_label.position = Vector2(100, 50)
	add_child(bonus_label)
	
	var tween = create_tween()
	tween.parallel().tween_property(bonus_label, "position", bonus_label.position + Vector2(0, -50), 1.0)
	tween.parallel().tween_property(bonus_label, "modulate:a", 0.0, 1.0)
	tween.tween_callback(bonus_label.queue_free)
