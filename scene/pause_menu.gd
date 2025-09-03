extends Control

signal resume_requested
signal pause_requested

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_process_input(true)
	visible = false

	$ColorRect.anchor_left = 0
	$ColorRect.anchor_top = 0
	$ColorRect.anchor_right = 1
	$ColorRect.anchor_bottom = 1

	$VBoxContainer/ResumeButton.pressed.connect(_on_resume_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		if visible:
			emit_signal("resume_requested")
		else:
			emit_signal("pause_requested")

func show_menu():
	visible = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func hide_menu():
	visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)

func _on_resume_pressed():
	emit_signal("resume_requested")

func _on_quit_pressed():
	get_tree().quit()
