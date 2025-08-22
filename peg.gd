extends StaticBody2D

@export var is_orange: bool = false
@export var points: int = 100
var is_hit: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready():
	if sprite:
		sprite.modulate = Color.ORANGE if is_orange else Color.BLUE

func hit_by_ball():
	if is_hit:
		return
	
	is_hit = true
	print("Peg hit! Breaking...")
	
	# Disable collision immediately
	collision.disabled = true
	
	# Visual breaking animation
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)
	tween.tween_property(sprite, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(sprite, "scale", Vector2.ZERO, 0.2)
	
	# Award points
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		game_manager.add_score(points)
		game_manager.peg_destroyed(is_orange)
	else:
		print("Score: ", points)
	
	# Remove peg after animation
	tween.finished.connect(func(): queue_free())
