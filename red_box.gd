# ColoredBucket.gd
extends Area2D

@export var bucket_color: String = "Red"
var moo_sound: AudioStreamPlayer2D

func _ready():
	body_entered.connect(_on_ball_entered)
	
	# Find the shared AudioStreamPlayer2D (it's a sibling of our parent)
	moo_sound = get_node_or_null("../AudioStreamPlayer2D")
	
	if moo_sound:
		print("MooSound found for ", bucket_color, " bucket")
	else:
		print("MooSound NOT found for ", bucket_color, " bucket")
	
	# Auto-detect color from node name if not set
	if bucket_color == "Red" and name != "":
		if name.to_lower().contains("yellow"):
			bucket_color = "Yellow"
		elif name.to_lower().contains("green"):
			bucket_color = "Green"
		elif name.to_lower().contains("red"):
			bucket_color = "Red"

func _on_ball_entered(body):
	if body is RigidBody2D:
		print("Ball entered ", bucket_color, " bucket area")
		
		# Play moo sound
		if moo_sound:
			print("Playing moo sound!")
			moo_sound.play()
		else:
			print("moo_sound is null!")
		
		# Stop the ball
		body.linear_velocity = Vector2.ZERO
		body.angular_velocity = 0.0
		body.freeze = true
		
		# Handle scoring
		var game_manager = get_tree().get_first_node_in_group("game_manager")
		if game_manager:
			var ball_color = game_manager.get_ball_color(body)
			game_manager.ball_entered_bucket(ball_color, bucket_color)
