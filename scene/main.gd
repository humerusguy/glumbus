extends Node3D

@onready var player = $SubViewportContainer/SubViewport/Player
var projectile_scene = preload("res://scene/bullet.tscn")

func _ready():
	player.shoot_requested.connect(spawn_projectile)

func spawn_projectile(spawn_transform, direction):
	var projectile = projectile_scene.instantiate()
	get_tree().root.add_child(projectile)
	projectile.global_position = spawn_transform.origin
	projectile.initialize(direction)
