extends Node2D

# Replace the single ball_scene with an array of different ball scenes
@export var ball_scenes: Array[PackedScene] = []
@export var ball_speed: float = 800.0
@export var max_angle: float = 75.0
@export var aim_line_length: float = 200.0
@export var show_trajectory: bool = true

var can_shoot: bool = true
var current_ball = null
var current_ball_scene: PackedScene
var next_ball_scene: PackedScene
var aim_angle: float = 0.0
var launch_position: Vector2
var mouse_position: Vector2

@onready var aim_line: Line2D = $AimLine
@onready var trajectory_line: Line2D = $TrajectoryLine
@onready var cannon: Sprite2D = $Cannon
@onready var next_ball_preview: Sprite2D = $NextBallPreview

func _ready():
	launch_position = global_position
	setup_aim_line()
	setup_trajectory_line()
	setup_next_ball_preview()
	
	# Initialize with random ball scenes
	if ball_scenes.size() > 0:
		current_ball_scene = get_random_ball_scene()
		next_ball_scene = get_random_ball_scene()
		update_preview_display()

func setup_next_ball_preview():
	if not next_ball_preview:
		next_ball_preview = Sprite2D.new()
		add_child(next_ball_preview)
	
	# Position preview ball (adjust as needed)
	next_ball_preview.position = Vector2(60, -30)  # Top-right of launcher
	next_ball_preview.scale = Vector2(0.7, 0.7)    # Slightly smaller

func get_random_ball_scene() -> PackedScene:
	if ball_scenes.size() == 0:
		push_error("No ball scenes assigned!")
		return null
	return ball_scenes[randi() % ball_scenes.size()]

func update_preview_display():
	if next_ball_preview and next_ball_scene:
		# Create a temporary instance to get its texture/appearance
		var temp_ball = next_ball_scene.instantiate()
		if temp_ball.has_node("Sprite2D"):
			var sprite = temp_ball.get_node("Sprite2D")
			next_ball_preview.texture = sprite.texture
			next_ball_preview.modulate = sprite.modulate
		temp_ball.queue_free()

func _process(delta):
	update_aiming()
	draw_aim_assistance()

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			print("Click detected!")
			print("can_shoot: ", can_shoot)
			print("current_ball exists: ", current_ball != null)
			print("current_ball valid: ", is_instance_valid(current_ball) if current_ball else "N/A")
			
			if can_shoot:
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
	if not current_ball_scene or not can_shoot or current_ball != null:
		return
	
	can_shoot = false
	current_ball = current_ball_scene.instantiate()
	get_parent().add_child(current_ball)
	current_ball.global_position = launch_position
	
	var aim_direction = Vector2(sin(deg_to_rad(aim_angle)), -cos(deg_to_rad(aim_angle)))
	var launch_velocity = aim_direction * ball_speed
	
	if current_ball.has_method("launch"):
		current_ball.launch(launch_velocity)
	
	# Update ball scenes for next shot
	current_ball_scene = next_ball_scene
	next_ball_scene = get_random_ball_scene()
	update_preview_display()
	
	if current_ball.has_signal("tree_exited"):
		current_ball.tree_exited.connect(_on_ball_destroyed)
	else:
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
