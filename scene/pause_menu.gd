extends Control

signal resume_requested
signal pause_requested

@onready var resume_button = $ColorRect/VBoxContainer/ResumeButton
@onready var quit_button = $ColorRect/VBoxContainer/QuitButton

func _ready():
	resume_button.pressed.connect(_on_resume_button_pressed)
	quit_button.pressed.connect(_on_quit_button_pressed)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if visible:
			emit_signal("resume_requested")
		else:
			emit_signal("pause_requested")

func show_menu():
	visible = true
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func hide_menu():
	visible = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func _on_resume_button_pressed():
	hide_menu()

func _on_quit_button_pressed():
	get_tree().quit()
