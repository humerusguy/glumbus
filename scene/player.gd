extends CharacterBody3D

const SPEED = 4.0
const JUMP_VELOCITY = 3.0

@export var pause_menu: Control
@export var projectile_scene: PackedScene
@export var shoot_cooldown: float = 0.25
@export var camera_target: Node3D

var camera: Camera3D
var is_game_paused = false
var shoot_timer: float = 0.0

func _ready():
	if pause_menu:
		pause_menu.connect("pause_requested", Callable(self, "_on_pause_requested"))
		pause_menu.connect("resume_requested", Callable(self, "_on_resume_requested"))
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	camera = get_viewport().get_camera_3d()
	if not camera:
		printerr("Error: No Camera3D found in the scene.")
		return
	if not camera_target:
		printerr("Error: No Camera Target Node found.")
		return

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
	_handle_movement()
	move_and_slide()

func _apply_gravity(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta

func _handle_movement():
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backward")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction != Vector3.ZERO:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

func _process(delta):
	if is_game_paused:
		return
	look_at_cursor()
	_handle_shooting(delta)

func look_at_cursor():
	if not camera:
		return
	var plane = Plane(Vector3.UP, global_transform.origin.y)
	var ray_length = 1000
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	var hit_point = plane.intersects_ray(from, to)
	if hit_point != null:
		var mesh = $MeshInstance3D
		var mesh_origin = mesh.global_transform.origin
		hit_point.y = mesh_origin.y
		mesh.look_at(hit_point, Vector3.UP)

func _handle_shooting(delta):
	if shoot_timer > 0.0:
		shoot_timer -= delta
	if Input.is_action_pressed("shoot") and shoot_timer <= 0.0:
		shoot_projectile()
		shoot_timer = shoot_cooldown

func shoot_projectile():
	if not projectile_scene:
		printerr("Error: Projectile scene not assigned in the Inspector.")
		return

	var plane = Plane(Vector3.UP, global_transform.origin.y)
	var ray_length = 1000
	var mouse_pos = get_viewport().get_mouse_position()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * ray_length
	var hit_point = plane.intersects_ray(from, to)

	if hit_point == null:
		return

	var projectile = projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)

	var direction = (hit_point - global_transform.origin).normalized()
	var mesh = $MeshInstance3D
	var spawn_pos = mesh.global_transform.origin + direction * 1.0

	projectile.global_transform.origin = spawn_pos
	projectile.initialize(direction)
