# PeggleLauncher.gd - Main launcher controller for Peggle-like game
extends Node2D

@export var ball_scene: PackedScene
@export var ball_speed: float = 800.0
@export var max_angle: float = 75.0  # Maximum angle from vertical (degrees)
@export var aim_line_length: float = 200.0
@export var aim_line_segments: int = 50
@export var trajectory_segments: int = 30
@export var show_trajectory: bool = true

var can_shoot: bool = true
var aim_angle: float = 0.0  # Angle from vertical (0 = straight up)
var launch_position: Vector2
var mouse_position: Vector2

@onready var aim_line: Line2D = $AimLine
@onready var trajectory_line: Line2D = $TrajectoryLine
@onready var cannon: Sprite2D = $Cannon

func _ready():
	launch_position = global_position
	setup_aim_line()
	setup_trajectory_line()

func _process(delta):
	update_aiming()
	draw_aim_assistance()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed and can_shoot:
			shoot_ball()

func update_aiming():
	mouse_position = get_global_mouse_position()
	
	# Calculate vector from launcher to mouse
	var mouse_offset = mouse_position - launch_position
	
	# Convert to angle from vertical (Peggle style)
	# In Peggle, 0 degrees is straight up, positive angles go right
	var angle_from_vertical = rad_to_deg(atan2(mouse_offset.x, -mouse_offset.y))
	
	# Clamp angle to valid range
	aim_angle = clamp(angle_from_vertical, -max_angle, max_angle)
	
	# Update cannon rotation
	if cannon:
		cannon.rotation = deg_to_rad(aim_angle)
	
	# Debug info
	print("Mouse Offset: ", mouse_offset)
	print("Aim Angle: ", aim_angle, "°")

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
	aim_line.add_point(Vector2.ZERO)  # Relative to launcher position
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
	var gravity = Vector2(0, 980)  # Gravity force
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
	
	# Re-enable shooting after delay (optional)
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
	trajectory_line.default_color = Color(1, 1, 0, 0.7)  # Semi-transparent yellow
	trajectory_line.z_index = 5
