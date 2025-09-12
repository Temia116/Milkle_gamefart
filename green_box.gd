# ColoredBucket.gd - Attach to each bucket Area2D
extends Area2D

@export var bucket_color: String = "Green"  # Set this in the editor for each bucket
var game_manager: Node

func _ready():
	body_entered.connect(_on_ball_entered)
	# Get reference to GameManager
	game_manager = get_node("/root/GameManager")  # Adjust path as needed
	
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
		print("Ball entered ", bucket_color, " bucket area (no scoring here)")
		
		# Don't modify ball physics at all - let it move naturally to BallCatcher
		# BallCatcher will handle the scoring
		print("Ball velocity after bucket entry: ", body.linear_velocity)
