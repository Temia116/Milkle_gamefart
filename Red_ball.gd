# Ball.gd - Save this as a separate script file
extends RigidBody2D

@export var bounce_damping: float = 0.8
@export var max_bounces: int = 50
@export var lifetime: float = 30.0

var bounce_count: int = 0
var initial_speed: float
var is_caught: bool = false  # Add this flag

func _ready():
	add_to_group("balls")  # Add this line
	setup_physics()
	setup_collision_detection()
	setup_lifetime_timer()

func setup_physics():
	gravity_scale = 1.0
	
	# Create and assign physics material for bounce
	var physics_material = PhysicsMaterial.new()
	physics_material.bounce = 0.7
	physics_material.friction = 0.1
	physics_material_override = physics_material

func setup_collision_detection():
	# Enable contact monitoring
	contact_monitor = true
	max_contacts_reported = 10
	
	# Connect collision signal
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func setup_lifetime_timer():
	var timer = Timer.new()
	timer.wait_time = lifetime
	timer.one_shot = true
	timer.timeout.connect(_on_lifetime_expired)
	add_child(timer)
	timer.start()

func launch(velocity: Vector2):
	linear_velocity = velocity
	initial_speed = velocity.length()

func _on_body_entered(body):
	# If ball has been caught, ignore further collisions
	if is_caught:
		return
		
	bounce_count += 1
	print("Ball hit: ", body.name)
	
	# Check if it's a bucket - stop bouncing (only if not caught)
	if body.is_in_group("buckets") or body.name.to_lower().contains("bucket"):
		print("Ball hit bucket - stopping bounce")
		linear_velocity *= 0.2
		angular_velocity = 0.0
		
		# Remove bounce
		if physics_material_override:
			physics_material_override.bounce = 0.0
			physics_material_override.friction = 1.5
		else:
			var new_material = PhysicsMaterial.new()
			new_material.bounce = 0.0
			new_material.friction = 1.5
			physics_material_override = new_material
	
	# Check if it's a peg and call hit_by_ball
	if body.has_method("hit_by_ball"):
		body.hit_by_ball()
	
	if bounce_count > 3:
		linear_velocity *= bounce_damping
	
	if bounce_count >= max_bounces:
		queue_free()

func _on_lifetime_expired():
	queue_free()

# Add this method to be called by BallCatcher
func mark_as_caught():
	is_caught = true

# Add this method to check if ball has stopped moving
func _physics_process(delta):
	# If ball is moving very slowly and has bounced a few times, consider it stopped
	if not is_caught and bounce_count > 5 and linear_velocity.length() < 50:
		await get_tree().create_timer(2.0).timeout
		if not is_caught and linear_velocity.length() < 50:  # Still slow after 2 seconds
			queue_free()
