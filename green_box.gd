# ColoredBucket.gd - Attach to each bucket Area2D
extends Area2D

@export var bucket_color: String = "Green"  # Set this in the editor for each bucket

func _ready():
	body_entered.connect(_on_ball_entered)
	
	# Auto-detect color from node name if not set
	if bucket_color == "Red" and name != "":
		if name.to_lower().contains("blue"):
			bucket_color = "Blue"
		elif name.to_lower().contains("green"):
			bucket_color = "Green"
		elif name.to_lower().contains("yellow"):
			bucket_color = "Yellow"
		# Red remains default

func _on_ball_entered(body):
	if body is RigidBody2D:  # This should be your ball
		print("Ball entered ", bucket_color, " bucket area")
		
		# Stop the ball immediately
		body.linear_velocity = Vector2.ZERO
		body.angular_velocity = 0.0
		# Optional: disable physics so it can't move anymore
		body.freeze = true
		
		# Find GameManager when we need it (not in _ready)
		var game_manager = get_tree().get_first_node_in_group("game_manager")
		if game_manager:
			var ball_color = game_manager.get_ball_color(body)
			game_manager.ball_entered_bucket(ball_color, bucket_color)
			print("Called GameManager scoring: ball=", ball_color, " bucket=", bucket_color)
		else:
			print("GameManager not found in group!")
			# Try alternative path as backup
			game_manager = get_node_or_null("../GameManager")  # Adjust path as needed
			if game_manager:
				print("Found GameManager via path!")
				var ball_color = game_manager.get_ball_color(body)
				game_manager.ball_entered_bucket(ball_color, bucket_color)
			else:
				print("GameManager not found anywhere!")
