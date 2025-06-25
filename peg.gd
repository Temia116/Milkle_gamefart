extends StaticBody2D

@export var is_orange: bool = false  # Orange pegs are targets
@export var points: int = 100
var is_hit: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready():
	# Set peg color based on type
	if sprite:
		sprite.modulate = Color.ORANGE if is_orange else Color.BLUE

func hit_by_ball():
	if is_hit:
		return
	
	is_hit = true
	
	# Visual feedback
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)
	tween.tween_property(sprite, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(sprite, "scale", Vector2.ZERO, 0.2)
	
	# Disable collision
	collision.disabled = true
	
	# Award points (connect to game manager)
	GameManager.add_score(points)
	
	# Remove after animation
	tween.finished.connect(func(): queue_free())
