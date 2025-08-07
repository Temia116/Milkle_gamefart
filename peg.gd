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
	
	# Particle effects (customize as needed)
	spawn_break_particles()
	
	# Sound effect
	AudioManager.play_sound("peg_hit")  # Adjust to your audio system
	
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

func spawn_break_particles():
	# Example particle spawn - customize based on peg type
	var particle_scene = preload("res://effects/PegBreakParticles.tscn")  # Adjust path
	if particle_scene:
		var particles = particle_scene.instantiate()
		get_parent().add_child(particles)
		particles.global_position = global_position
		
		# Customize particles based on peg color
		if is_orange:
			particles.modulate = Color.ORANGE
		else:
			particles.modulate = Color.BLUE
