# BallCatcher.gd
extends Area2D

func _ready():
	# Connect to detect when ball enters
	body_entered.connect(_on_ball_entered)

func _on_ball_entered(body):
	if body.name.contains("Ball"):
		print("Ball caught! Ready for next shot.")
		
		# Remove the ball
		body.queue_free()
		
		# Tell launcher it can shoot again
		var launcher = get_parent().get_node("PeggleLauncher")
		if launcher:
			launcher.current_ball = null
			launcher.can_shoot = true
