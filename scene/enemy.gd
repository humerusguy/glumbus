extends CharacterBody3D

@export var max_health: int = 50
var current_health: int

@export var speed: float = 3.0
@export var attack_range: float = 2.5
@export var damage: int = 10
@export var attack_rate: float = 1.0

const UPDATE_TIME = 0.2
const SMOOTHING_FACTOR = 0.1

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var player: CharacterBody3D
var state = "MOVE"

@onready var agent = $NavigationAgent3D
@onready var attack_area = $Area3D
@onready var attack_timer = Timer.new()

var update_timer := 0.0

func _ready() -> void:
	current_health = max_health

	player = get_tree().get_first_node_in_group("Player")
	if player:
		print("Player found!")
	else:
		print("Error: Player not found!")

	add_child(attack_timer)
	attack_timer.wait_time = 1.0 / attack_rate
	attack_timer.one_shot = false
	attack_timer.timeout.connect(_on_attack_timer_timeout)

	attack_area.body_entered.connect(_on_attack_area_body_entered)
	attack_area.body_exited.connect(_on_attack_area_body_exited)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

	if player:
		match state:
			"MOVE":
				_move_to_player(delta)
			"ATTACK":
				_attack_player()
	
	move_and_slide()

func _move_to_player(delta: float) -> void:
	update_timer -= delta
	if update_timer <= 0.0:
		update_timer = UPDATE_TIME
		if player:
			agent.set_target_position(player.global_position)

	if agent.is_navigation_finished():
		velocity.x = 0
		velocity.z = 0
		return
		
	var next_pos = agent.get_next_path_position()
	var dir = (next_pos - global_position).normalized()
	dir.y = 0
	
	var current_facing = -global_transform.basis.z
	var new_dir = current_facing.slerp(dir, SMOOTHING_FACTOR).normalized()
	look_at(global_position + new_dir, Vector3.UP)
	
	velocity.x = new_dir.x * speed
	velocity.z = new_dir.z * speed

func _attack_player() -> void:
	velocity.x = 0
	velocity.z = 0

func _on_attack_area_body_entered(body: Node3D) -> void:
	if body == player:
		state = "ATTACK"
		attack_timer.start()
		print("Player entered attack range!")

func _on_attack_area_body_exited(body: Node3D) -> void:
	if body == player:
		state = "MOVE"
		attack_timer.stop()
		print("Player exited attack range.")
		
func _on_attack_timer_timeout() -> void:
	if player and global_position.distance_to(player.global_position) <= attack_range:
		if player.has_method("take_damage"):
			player.take_damage(damage)
			print("Successful attack! Player took ", damage, " damage.")

func take_damage(damage_amount: int) -> void:
	if current_health <= 0:
		return
		
	current_health -= damage_amount
	print("Enemy took ", damage_amount, " damage. Health: ", current_health)
	
	if current_health <= 0:
		_on_death()

func _on_death() -> void:
	print("Enemy has been defeated!")
	queue_free()
