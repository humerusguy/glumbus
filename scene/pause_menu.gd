extends Control

@onready var resume_button = $ColorRect/VBoxContainer/ResumeButton
@onready var quit_button = $ColorRect/VBoxContainer/QuitButton

func _ready() -> void:
	# Connect button signals
	resume_button.pressed.connect(_on_resume_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

	hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			unpause()
		else:
			pause()

func pause() -> void:
	show()
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func unpause() -> void:
	hide()
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func _on_resume_button_pressed() -> void:
	unpause()

func _on_quit_button_pressed() -> void:
	get_tree().quit()
