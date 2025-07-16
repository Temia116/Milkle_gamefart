# cannon.gd - Fixed script structure
# This script should be attached to the main launcher node, NOT the cannon sprite

extends Node2D

@export var ball_scene: PackedScene
@export var ball_speed: float = 800.0
@export var max_angle: float = 75.0
@export var aim_line_length: float = 200.0
@export var aim_line_segments: int = 50
@export var trajectory_segments: int = 30
@export var show_trajectory: bool = true

var can_shoot: bool = true
var aim_angle: float = 0.0
var launch_position: Vector2
var mouse_position: Vector2

# FIXED: These should reference child nodes, not the node this script is on
@onready var aim_line: Line2D = $AimLine
@onready var trajectory_line: Line2D = $TrajectoryLine
@onready var cannon_sprite: Sprite2D = $CannonSprite  # Renamed to avoid confusion

func _ready():
	print("=== CANNON SCRIPT _ready() ===")
	launch_position = global_position
	print("Launch position: ", launch_position)
	
	setup_aim_line()
	setup_trajectory_line()
	
	print("Aim line: ", aim_line)
	print("Trajectory line: ", trajectory_line)
	print("Cannon sprite: ", cannon_sprite)
	print("==============================")

func _process(delta):
	update_aiming()
	draw_aim_assistance()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and can_shoot:
			shoot_ball()

func update_aiming():
	mouse_position = get_global_mouse_position()
	
	# Calculate direction
	var direction = mouse_position - launch_position
	
	# Calculate angle
	var raw_angle = rad_to_deg(atan2(direction.x, -direction.y))
	
	# Clamp angle
	aim_angle = clamp(raw_angle, -max_angle, max_angle)
	
	# Update cannon sprite rotation (NOT the node this script is on)
	if cannon_sprite:
		cannon_sprite.rotation = deg_to_rad(aim_angle)
	
	# Debug
	print("Mouse: ", mouse_position, " | Angle: ", raw_angle, "° -> ", aim_angle, "°")

func draw_aim_assistance():
	update_aim_line()
	if show_trajectory:
		update_trajectory_preview()

func update_aim_line():
	if not aim_line:
		return
		
	aim_line.clear_points()
	
	# Calculate aim direction
	var aim_direction = Vector2(sin(deg_to_rad(aim_angle)), -cos(deg_to_rad(aim_angle)))
	
	# Draw aim line
	var end_point = launch_position + aim_direction * aim_line_length
	aim_line.add_point(Vector2.ZERO)
	aim_line.add_point(to_local(end_point))

func update_trajectory_preview():
	if not trajectory_line:
		return
		
	trajectory_line.clear_points()
	
	# Calculate initial velocity
	var aim_direction = Vector2(sin(deg_to_rad(aim_angle)), -cos(deg_to_rad(aim_angle)))
	var initial_velocity = aim_direction * ball_speed
	
	# Simulate trajectory
	var pos = launch_position
	var velocity = initial_velocity
	var gravity = Vector2(0, 980)
	var time_step = 0.02
	
	for i in range(trajectory_segments):
		trajectory_line.add_point(to_local(pos))
		
		# Update physics
		velocity += gravity * time_step
		pos += velocity * time_step
		
		# Stop if ball goes off screen
		if pos.y > get_viewport().size.y + 100:
			break

func shoot_ball():
	if not ball_scene or not can_shoot:
		return
	
	can_shoot = false
	
	# Create ball
	var ball = ball_scene.instantiate()
	get_parent().add_child(ball)
	ball.global_position = launch_position
	
	# Calculate launch direction and velocity
	var aim_direction = Vector2(sin(deg_to_rad(aim_angle)), -cos(deg_to_rad(aim_angle)))
	var launch_velocity = aim_direction * ball_speed
	
	# Setup ball
	if ball.has_method("launch"):
		ball.launch(launch_velocity)
	
	# Re-enable shooting after delay
	await get_tree().create_timer(1.0).timeout
	can_shoot = true

func setup_aim_line():
	if not aim_line:
		aim_line = Line2D.new()
		add_child(aim_line)
	
	aim_line.width = 3.0
	aim_line.default_color = Color.RED
	aim_line.z_index = 10

func setup_trajectory_line():
	if not trajectory_line:
		trajectory_line = Line2D.new()
		add_child(trajectory_line)
	
	trajectory_line.width = 2.0
	trajectory_line.default_color = Color(1, 1, 0, 0.7)
	trajectory_line.z_index = 5

# ALTERNATIVE: If you want this script ON the cannon sprite itself
# Use this version instead:

# cannon.gd - Alternative version if attached to the cannon sprite
# extends Sprite2D
# 
# @export var ball_scene: PackedScene
# @export var ball_speed: float = 800.0
# @export var max_angle: float = 75.0
# @export var aim_line_length: float = 200.0
# @export var show_trajectory: bool = true
# 
# var can_shoot: bool = true
# var aim_angle: float = 0.0
# var launch_position: Vector2
# var mouse_position: Vector2
# 
# var aim_line: Line2D
# var trajectory_line: Line2D
# 
# func _ready():
#     # If this script is on the cannon sprite, use its position
#     launch_position = global_position
#     setup_aim_line()
#     setup_trajectory_line()
# 
# func _process(delta):
#     update_aiming()
#     draw_aim_assistance()
# 
# func update_aiming():
#     mouse_position = get_global_mouse_position()
#     
#     # Calculate direction
#     var direction = mouse_position - launch_position
#     
#     # Calculate angle
#     var raw_angle = rad_to_deg(atan2(direction.x, -direction.y))
#     
#     # Clamp angle
#     aim_angle = clamp(raw_angle, -max_angle, max_angle)
#     
#     # Update THIS sprite's rotation (since script is on the cannon)
#     rotation = deg_to_rad(aim_angle)
#     
#     print("Angle: ", raw_angle, "° -> ", aim_angle, "°")
# 
# # ... rest of the functions remain the same
