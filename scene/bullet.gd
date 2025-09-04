extends CharacterBody3D

@export var speed: float = 20.0
@export var lifetime: float = 2.0
@export var damage: int = 10

var direction: Vector3 = Vector3.ZERO
var time_alive: float = 0.0

@onready var ray_cast = $RayCast3D

func _ready() -> void:
	ray_cast.set_collision_mask_value(1, true)

func _physics_process(delta: float) -> void:
	ray_cast.target_position = direction * speed * delta
	ray_cast.force_raycast_update()

	if ray_cast.is_colliding():
		var collider = ray_cast.get_collider()
		if collider:
			print("Bullet hit: ", collider.name)
			_on_despawn("collision")
	else:
		velocity = direction * speed
		move_and_slide()

	time_alive += delta
	if time_alive >= lifetime:
		_on_despawn("lifetime expired")
		
	_culling_check()

func _on_despawn(reason: String) -> void:
	print("Bullet despawning: ", reason)
	queue_free()

func _culling_check() -> void:
	var camera = get_viewport().get_camera_3d()
	if camera:
		var viewport_pos = camera.unproject_position(global_transform.origin)
		var screen_size = get_viewport().get_visible_rect().size
		
		var is_outside_x = viewport_pos.x < 0 or viewport_pos.x > screen_size.x
		var is_outside_y = viewport_pos.y < 0 or viewport_pos.y > screen_size.y
		
		if is_outside_x or is_outside_y:
			_on_despawn("culling")

func initialize(new_direction: Vector3) -> void:
	direction = new_direction.normalized()
	if direction != Vector3.ZERO:
		look_at(global_transform.origin + direction)
