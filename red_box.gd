# ColoredBucket.gd
extends Area2D

@export var bucket_color: String = "Red"
var moo_sound: AudioStreamPlayer2D

func _ready():
	body_entered.connect(_on_ball_entered)
	if moo_sound:
		moo_sound.bus = "SFX"
	# Try multiple paths to find the AudioStreamPlayer2D
	var possible_paths = [
		"../AudioStreamPlayer2D",           # Sibling of parent
		"../../AudioStreamPlayer2D",        # Grandparent's child
		"../../../AudioStreamPlayer2D",     # Great-grandparent's child
		"AudioStreamPlayer2D"               # Direct child
	]
	
	for path in possible_paths:
		moo_sound = get_node_or_null(path)
		if moo_sound:
			print("Found MooSound at path: ", path, " for ", bucket_color, " bucket")
			break
		else:
			print("Path failed: ", path)
	
	if not moo_sound:
		print("MooSound NOT found anywhere for ", bucket_color, " bucket")
		print("Current node path: ", get_path())
		print("Parent node: ", get_parent().name if get_parent() else "no parent")

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
