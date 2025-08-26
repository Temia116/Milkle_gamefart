# Bucket.gd - With ball limit
extends StaticBody2D

@onready var area: Area2D = $Area2D
var balls_in_bucket = []
@export var max_balls: int = 5  # Maximum balls to keep

func _ready():
	if area:
		area.body_entered.connect(_on_ball_collected)

func _on_ball_collected(body):
	if body.name.contains("Ball") or body.has_method("launch"):
		print("Ball collected!")
		
		balls_in_bucket.append(body)
		
		# Remove oldest ball if too many
		if balls_in_bucket.size() > max_balls:
			var oldest_ball = balls_in_bucket.pop_front()
			if is_instance_valid(oldest_ball):
				oldest_ball.queue_free()
		
		# Reset launcher
		var launcher = get_tree().current_scene.get_node("Launcher")
		if launcher:
			launcher.current_ball = null
			launcher.can_shoot = true
