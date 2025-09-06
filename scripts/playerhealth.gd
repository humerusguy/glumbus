extends CharacterBody3D

@export var max_health: int = 100
var current_health: int

# A signal to let other nodes know when the health has changed.
signal health_changed(new_health)
# A signal to broadcast when the player is defeated.
signal died

func _ready() -> void:
	current_health = max_health

func take_damage(damage_amount: int) -> void:
	# Only take damage if the player is still alive.
	if current_health <= 0:
		return
		
	current_health -= damage_amount
	print("Player took ", damage_amount, " damage. Health: ", current_health)
	
	# Emit the signal to update the UI or other systems.
	emit_signal("health_changed", current_health)
	
	# Check if the player has been defeated.
	if current_health <= 0:
		_on_death()

func _on_death() -> void:
	print("Player has been defeated!")
	# Emit the death signal.
	emit_signal("died")
	# Queue the player for deletion after a delay
	queue_free()
