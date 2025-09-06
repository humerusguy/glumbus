extends Node3D

@export var enemy_scene: PackedScene
@export var spawn_locations: Array[Node3D]
@export var spawn_interval: float = 5.0
@export var max_enemies: int = 10

var enemies_on_screen: int = 0
var spawn_timer: Timer

func _ready() -> void:
	# Check if a scene and spawn locations are set
	if not enemy_scene or spawn_locations.is_empty():
		printerr("Enemy scene or spawn locations not configured.")
		return

	# Set up the spawn timer
	spawn_timer = Timer.new()
	add_child(spawn_timer)
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_spawn_timer_timeout)
	spawn_timer.start()

func _on_spawn_timer_timeout() -> void:
	if enemies_on_screen < max_enemies:
		spawn_enemy()

func spawn_enemy() -> void:
	var spawn_location = spawn_locations.pick_random()
	if not spawn_location:
		return
		
	var enemy = enemy_scene.instantiate()
	get_tree().current_scene.add_child(enemy)
	enemy.global_position = spawn_location.global_position
	
	# Increment the enemy count
	enemies_on_screen += 1
	
	# Connect the enemy's `died` signal to the spawner
	if enemy.has_signal("died"):
		enemy.died.connect(_on_enemy_died)

func _on_enemy_died() -> void:
	enemies_on_screen -= 1
