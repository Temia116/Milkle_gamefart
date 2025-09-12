# BallCatcher.gd
extends Area2D

func _ready():
	# Connect to detect when ball enters
	body_entered.connect(_on_ball_entered)

func _on_ball_entered(body):
	# Check if it's a RigidBody2D (which your balls are) instead of name
	if body is RigidBody2D:
		print("Ball caught! Ready for next shot. Ball: ", body.name)
		
		# Remove the ball
		body.queue_free()
		
		# Tell launcher it can shoot again
		var launcher = get_parent().get_node("Launcher")  # Adjust path if needed
		if launcher:
			launcher.current_ball = null
			launcher.can_shoot = true
			print("Launcher can shoot again!")
