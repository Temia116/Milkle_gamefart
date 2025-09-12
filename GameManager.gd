# GameManager.gd - Updated with color matching system
extends Node

var score: int = 0
var orange_pegs_left: int = 0

# Color matching bonus system
@export var color_match_bonus: int = 50
@export var regular_bucket_points: int = 10

signal score_changed(new_score: int)
signal orange_peg_hit()
signal bonus_earned(points: int, reason: String)

func _on_score_changed(new_score: int):
	pass

func _ready():
	print("ScoreUI _ready() called!")
	
	# Wait a frame to ensure everything is in the scene tree
	await get_tree().process_frame
	
	# Connect to GameManager's score signal using group
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	print("ScoreUI - Trying to find GameManager in group")
	
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
	
	update_score_display()
	print("ScoreUI _ready() called!")
	
	# Wait a frame to ensure everything is in the scene tree
	await get_tree().process_frame
	
	# Connect to GameManager's score signal using group
	print("ScoreUI - Trying to find GameManager in group")
	
	if game_manager:
		print("ScoreUI - GameManager found: true")
		if game_manager.has_signal("score_changed"):
			print("ScoreUI - score_changed signal exists: true")
			# Fix the connection - use the correct function name
			game_manager.score_changed.connect(_on_score_changed)
			print("Connected to score_changed signal")
		else:
			print("ScoreUI - score_changed signal exists: false")
	else:
		print("ScoreUI - GameManager found: false")
	
	

func add_score(points: int):
	score += points
	score_changed.emit(score)
	print("Score: ", score)

func add_bonus_score(points: int, reason: String = "Bonus"):
	score += points
	score_changed.emit(score)
	bonus_earned.emit(points, reason)
	print("Bonus! +", points, " - ", reason, " | Total Score: ", score)

func count_orange_pegs():
	var pegs = get_tree().get_nodes_in_group("pegs")
	orange_pegs_left = 0
	for peg in pegs:
		if peg.is_orange:
			orange_pegs_left += 1
	print("Orange pegs: ", orange_pegs_left)

func peg_destroyed(was_orange: bool):
	if was_orange:
		orange_pegs_left -= 1
		orange_peg_hit.emit()
		if orange_pegs_left <= 0:
			print("Level Complete!")

# Call this when ball enters a bucket
func ball_entered_bucket(ball_color: String, bucket_color: String):
	if ball_color.to_lower() == bucket_color.to_lower():
		# Color match bonus!
		add_bonus_score(color_match_bonus, "Color Match")
	else:
		# Regular bucket points
		add_score(regular_bucket_points)

# Helper function to get ball color from ball node
func get_ball_color(ball_node) -> String:
	# Try different ways to get the color
	if ball_node.has_method("get_ball_color"):
		return ball_node.get_ball_color()
	elif "ball_color" in ball_node:
		return ball_node.ball_color
	elif ball_node.name.contains("Red"):
		return "Red"
	elif ball_node.name.contains("Blue"):
		return "Blue"
	elif ball_node.name.contains("Green"):
		return "Green"
	elif ball_node.name.contains("Yellow"):
		return "Yellow"
	else:
		# Try to determine from scene file name
		var scene_file = ball_node.scene_file_path
		if scene_file:
			if scene_file.contains("Red"):
				return "Red"
			elif scene_file.contains("Blue"):
				return "Blue"
			elif scene_file.contains("Green"):
				return "Green"
			elif scene_file.contains("Yellow"):
				return "Yellow"
	
	return "Unknown"
	
func update_score_display():
	print("update_score_display() called, current_score:", current_score)
	if score_label:
		score_label.text = "Score: " + str(current_score)
		print("Score label updated to:", score_label.text)
	else:
		print("ERROR: score_label is null!")
		# Try to find the label again
		score_label = get_node_or_null("ScoreLabel")
		if score_label:
			print("Found ScoreLabel on retry")
			score_label.text = "Score: " + str(current_score)
		else:
			print("ScoreLabel still not found")
