extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


signal resume
signal next_level
signal restart
signal main_Menu
signal quit

func _on_resume_btn_pressed() -> void:
	emit_signal("resume")

func _on_restart_btn_pressed() -> void:
	emit_signal("restart")

func _on_main_menu_btn_pressed() -> void:
	emit_signal("main_Menu")

func _on_quit_btn_pressed() -> void:
	emit_signal("quit")

func _on_next_btn_pressed() -> void:
	emit_signal("next_level")
