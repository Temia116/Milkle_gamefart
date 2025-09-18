# GameManager.gd - Updated with color matching system
extends Node
@onready var background_music = $BackgroundMusic
var score: int = 0
var orange_pegs_left: int = 0
# Color matching bonus system
@export var color_match_bonus: int = 50
@export var regular_bucket_points: int = 10
signal score_changed(new_score: int)
signal orange_peg_hit()
signal bonus_earned(points: int, reason: String)
func _ready():
	add_to_group("game_manager")  # Add this line
	await get_tree().process_frame
	count_orange_pegs()
	background_music.bus = "Music"

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
	
