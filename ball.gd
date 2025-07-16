extends RigidBody2D
@export var bounce_damping: float = 0.8
@export var max_bounces: int = 50
@export var lifetime: float = 30.0
var bounce_count: int = 0
var initial_speed: float

func _ready():
	# IMPORTANT: Set these physics properties
	gravity_scale = 1.0
	
	# Create physics material
	var physics_material = PhysicsMaterial.new()
	physics_material.bounce = 0.7
	physics_material.friction = 0.1  # Low friction for smooth movement
	physics_material = physics_material
	
	# Make sure the ball starts awake
	sleeping = false
	can_sleep = false  # Prevent sleeping initially
	
	# Connect collision signal
	body_entered.connect(_on_body_entered)
	
	# Lifetime timer
	var timer = Timer.new()
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.timeout.connect(_on_lifetime_expired)
	add_child(timer)
	timer.start()

func launch(velocity: Vector2):
	print("=== BALL LAUNCH DEBUG ===")
	print("Launch velocity: ", velocity)
	print("Velocity magnitude: ", velocity.length())
	print("Ball position: ", global_position)
	print("Ball gravity_scale: ", gravity_scale)
	print("Ball mass: ", mass)
	print("Ball sleeping: ", sleeping)
	
	# CRITICAL: Make sure ball is not sleeping
	sleeping = false
	
	# Apply the velocity
	linear_velocity = velocity
	initial_speed = velocity.length()
	
	# Verify the velocity was set
	print("Linear velocity after setting: ", linear_velocity)
	print("========================")
	
	# Optional: Add a small delay before enabling sleep
	await get_tree().create_timer(0.5).timeout
	can_sleep = true

func _on_body_entered(body):
	bounce_count += 1
	
	if body.has_method("hit_by_ball"):
		body.hit_by_ball()
	
	if bounce_count > 3:
		linear_velocity *= bounce_damping
	
	if bounce_count >= max_bounces:
		queue_free()

func _on_lifetime_expired():
	queue_free()
