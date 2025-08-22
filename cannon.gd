extends Node2D

@export var ball_scene: PackedScene
@export var ball_speed: float = 800.0
@export var max_angle: float = 75.0
@export var aim_line_length: float = 200.0
@export var show_trajectory: bool = true

var can_shoot: bool = true
var current_ball = null
var aim_angle: float = 0.0
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
	var mouse_offset = mouse_position - launch_position
	var angle_from_vertical = rad_to_deg(atan2(mouse_offset.x, -mouse_offset.y))
	aim_angle = clamp(angle_from_vertical, -max_angle, max_angle)
	
	if cannon:
		cannon.rotation = deg_to_rad(aim_angle)

func draw_aim_assistance():
	update_aim_line()
	if show_trajectory:
		update_trajectory_preview()

func update_aim_line():
	if not aim_line:
		return
	
	aim_line.clear_points()
	var aim_direction = Vector2(sin(deg_to_rad(aim_angle)), -cos(deg_to_rad(aim_angle)))
	var end_point = launch_position + aim_direction * aim_line_length
	aim_line.add_point(Vector2.ZERO)
	aim_line.add_point(to_local(end_point))

func update_trajectory_preview():
	if not trajectory_line:
		return
	
	trajectory_line.clear_points()
	var aim_direction = Vector2(sin(deg_to_rad(aim_angle)), -cos(deg_to_rad(aim_angle)))
	var initial_velocity = aim_direction * ball_speed
	var pos = launch_position
	var velocity = initial_velocity
	var gravity = Vector2(0, 980)
	var time_step = 0.02
	
	for i in range(30):
		trajectory_line.add_point(to_local(pos))
		velocity += gravity * time_step
		pos += velocity * time_step
		if pos.y > get_viewport().size.y + 100:
			break

func shoot_ball():
	if not ball_scene or not can_shoot or current_ball != null:
		return
	
	can_shoot = false
	current_ball = ball_scene.instantiate()
	get_parent().add_child(current_ball)
	current_ball.global_position = launch_position
	
	var aim_direction = Vector2(sin(deg_to_rad(aim_angle)), -cos(deg_to_rad(aim_angle)))
	var launch_velocity = aim_direction * ball_speed
	
	if current_ball.has_method("launch"):
		current_ball.launch(launch_velocity)
	
	# Connect to ball's cleanup to know when it's gone
	if current_ball.has_signal("tree_exited"):
		current_ball.tree_exited.connect(_on_ball_destroyed)
	else:
		# Fallback - check periodically if ball still exists
		start_ball_check()

func _on_ball_destroyed():
	current_ball = null
	can_shoot = true

func start_ball_check():
	var timer = Timer.new()
	add_child(timer)
	timer.wait_time = 0.1
	timer.timeout.connect(_check_ball_exists)
	timer.start()

func _check_ball_exists():
	if current_ball == null or not is_instance_valid(current_ball):
		current_ball = null
		can_shoot = true
		# Remove the timer
		for child in get_children():
			if child is Timer:
				child.queue_free()
				break

func setup_aim_line():
	if not aim_line:
		aim_line = Line2D.new()
		add_child(aim_line)
	aim_line.width = 3.0
	aim_line.default_color = Color.RED

func setup_trajectory_line():
	if not trajectory_line:
		trajectory_line = Line2D.new()
		add_child(trajectory_line)
	trajectory_line.width = 2.0
	trajectory_line.default_color = Color(1, 1, 0, 0.7)
