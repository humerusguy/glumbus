extends Node3D

var projectile_scene = preload("res://scene/bullet.tscn")

func spawn_projectile(spawn_transform, direction):
	var projectile = projectile_scene.instantiate()
	get_tree().root.add_child(projectile)
	projectile.global_position = spawn_transform.origin
	projectile.initialize(direction)
