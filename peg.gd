extends StaticBody2D

@export var is_orange: bool = false
@export var points: int = 100
var is_hit: bool = false

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var hit_area: Area2D = $HitArea

func _ready():
	# Set peg color based on type
	if sprite:
		sprite.modulate = Color.ORANGE if is_orange else Color.BLUE
	
	# Connect hit detection
	if hit_area:
		hit_area.body_entered.connect(_on_hit_area_body_entered)
	
	add_to_group("pegs")

func _on_hit_area_body_entered(body):
	if body.is_in_group("ball"):
		hit_by_ball()

func hit_by_ball():
	if is_hit:
		return
	
	is_hit = true
	
	# Particle effects (custom
	
	# Sound effect
	
	# Visual feedback
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.1)
	tween.tween_property(sprite, "scale", Vector2(1.2, 1.2), 0.1)
	tween.tween_property(sprite, "scale", Vector2.ZERO, 0.2)
	
	# Disable both collisions
	collision.disabled = true
	hit_area.get_child(0).disabled = true  # Disable hit area collision
	
	# Award points
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		game_manager.add_score(points)
		game_manager.peg_destroyed(is_orange)
	
	# Remove after animation
	tween.finished.connect(func(): queue_free())
