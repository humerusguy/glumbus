extends CharacterBody3D

const SPEED = 4.0
const JUMP_VELOCITY = 3.0


@export var pause_menu: Control

var is_game_paused = false

func _ready():
	pause_menu.connect("pause_requested", Callable(self, "_on_pause_requested"))
	pause_menu.connect("resume_requested", Callable(self, "_on_resume_requested"))
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func _on_pause_requested():
	toggle_pause()

func _on_resume_requested():
	toggle_pause()

func toggle_pause():
	is_game_paused = !is_game_paused
	get_tree().paused = is_game_paused
	if is_game_paused:
		pause_menu.show_menu()
	else:
		pause_menu.hide_menu()

func _physics_process(delta):
	if is_game_paused:
		return

	_apply_gravity(delta)
	_handle_jump()
	_handle_movement()
	move_and_slide()

func _apply_gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

func _handle_jump():
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

func _handle_movement():
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction != Vector3.ZERO:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

func _process(_delta):
	look_at_cursor()

func look_at_cursor():
	var plane = Plane(Vector3.UP, global_transform.origin.y)
	var ray_length = 1000
	var mouse_pos = get_viewport().get_mouse_position()
	var camera = get_viewport().get_camera_3d()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	
	var hit_point = plane.intersects_ray(from, to)
	if hit_point != null:
		var mesh = $MeshInstance3D
		var mesh_origin = mesh.global_transform.origin

		hit_point.y = mesh_origin.y
		mesh.look_at(hit_point, Vector3.UP)
