extends RigidBody2D

@export var bounce_damping: float = 0.8
@export var max_bounces: int = 50
@export var lifetime: float = 30.0

var bounce_count: int = 0
var initial_speed: float

func _ready():
	gravity_scale = 1.0
	
	# Create and assign physics material for bounce
	var physics_material = PhysicsMaterial.new()
	physics_material.bounce = 0.7
	physics_material.friction = 0.1
	physics_material_override = physics_material
	
	# Enable contact monitoring
	contact_monitor = true
	max_contacts_reported = 10
	
	# Connect collision signal
	body_entered.connect(_on_body_entered)
	
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
	bounce_count += 1
	print("Ball hit: ", body.name)
	
	# Check if it's a peg and call hit_by_ball
	if body.has_method("hit_by_ball"):
		body.hit_by_ball()
	
	if bounce_count > 3:
		linear_velocity *= bounce_damping
	
	if bounce_count >= max_bounces:
		queue_free()

func _on_lifetime_expired():
	queue_free()
