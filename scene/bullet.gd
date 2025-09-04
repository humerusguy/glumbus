extends CharacterBody3D

@export var speed: float = 20.0
@export var lifetime: float = 2.0
@export var damage: int = 10
@export var target_groups: Array = ["Enemy", "Wall"]

var direction: Vector3 = Vector3.ZERO
var time_alive: float = 0.0

func _physics_process(delta: float) -> void:
	velocity = direction * speed
	
	_culling_check()

	if move_and_slide():
		var collision = get_last_slide_collision()
		if collision:
			_on_despawn("collision")

	time_alive += delta
	if time_alive >= lifetime:
		_on_despawn("lifetime expired")

func _on_despawn(reason: String) -> void:
	print("Bullet despawning: ", reason)
	queue_free()

func _culling_check() -> void:
	var camera = get_viewport().get_camera_3d()
	if camera:
		var viewport = get_viewport()
		var screen_size = viewport.get_visible_rect().size
		var viewport_pos = camera.unproject_position(global_transform.origin)
		
		var is_outside_x = viewport_pos.x < 0 or viewport_pos.x > screen_size.x
		var is_outside_y = viewport_pos.y < 0 or viewport_pos.y > screen_size.y
		var is_behind_camera = camera.is_position_behind(global_transform.origin)
		
		if is_outside_x or is_outside_y or is_behind_camera:
			_on_despawn("culling")

func initialize(new_direction: Vector3) -> void:
	direction = new_direction
	if direction != Vector3.ZERO:
		look_at(global_transform.origin + direction)
