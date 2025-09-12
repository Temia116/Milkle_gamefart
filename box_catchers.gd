# BallCatcher.gd - Updated with scoring
extends Area2D

@export var bucket_color: String = "Red"  # Set this for each BallCatcher
var game_manager: Node

func _ready():
	# Connect to detect when ball enters
	body_entered.connect(_on_ball_entered)
	# Get reference to GameManager - try multiple ways
	game_manager = get_tree().get_first_node_in_group("game_manager")
	if not game_manager:
		# Try to find it by name in the scene
		game_manager = get_tree().current_scene.get_node("GameManager")
	if not game_manager:
		# Try to find any node with GameManager script
		var all_nodes = get_tree().get_nodes_in_group("game_manager")
		if all_nodes.size() > 0:
			game_manager = all_nodes[0]
	
	print("GameManager found: ", game_manager != null)
	
	# Auto-detect color from parent bucket name if not set manually
	if bucket_color == "Red":
		var parent_name = get_parent().name.to_lower()
		if parent_name.contains("blue"):
			bucket_color = "Blue"
		elif parent_name.contains("green"):
			bucket_color = "Green"
		elif parent_name.contains("yellow"):
			bucket_color = "Yellow"

func _on_ball_entered(body):
	print("BallCatcher triggered by: ", body.name)
	if body is RigidBody2D:
		print("Ball caught in ", bucket_color, " bucket! Ready for next shot.")
		
		# Debug GameManager connection
		print("GameManager found: ", game_manager != null)
		if game_manager:
			var ball_color = game_manager.get_ball_color(body)
			print("Scoring: Ball color: ", ball_color, " | Bucket color: ", bucket_color)
			game_manager.ball_entered_bucket(ball_color, bucket_color)
		else:
			print("ERROR: GameManager not found!")
		
		# Mark ball as caught so it stops processing collisions
		if body.has_method("mark_as_caught"):
			body.mark_as_caught()
			print("Ball marked as caught")
		else:
			print("Ball doesn't have mark_as_caught method")
		
		# Debug launcher path
		var launcher = get_parent().get_node("Launcher")
		print("Launcher found: ", launcher != null)
		if launcher:
			launcher.current_ball = null
			launcher.can_shoot = true
			print("Launcher reset - can_shoot: ", launcher.can_shoot)
		else:
			print("ERROR: Launcher not found! Trying different paths...")
			# Try alternative paths
			launcher = get_tree().get_first_node_in_group("launcher")
			if launcher:
				print("Found launcher in group")
				launcher.current_ball = null
				launcher.can_shoot = true
		
		# Remove the ball
		print("Destroying ball...")
		body.queue_free()
