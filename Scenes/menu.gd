extends Control

@onready var scroll_container = $ScrollContainer
@onready var levels: Array = get_node("ScrollContainer/VBoxContainer/Background/Top/Level_Grid").get_children()
var sound_on := true


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().process_frame
	scroll_to_section("center")

	# Unlock level buttons
	var first = true
	for i in levels.size():
		var level_button = levels[i]
		var level_num = i + 1 # assuming index 0 is level 1
		if GameState.unlocked_levels.has(level_num):
			level_button.disabled = false
		else:
			level_button.disabled = true
		level_button.pressed.connect(_on_level_pressed.bind(level_button))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_level_pressed(button: level_button):
	var level_path = button.get_meta("level_path")
	if level_path:
		get_tree().change_scene_to_file(level_path)


func scroll_to_section(section: String):
	var target_pos := 0
	var viewport_height = scroll_container.get_v_scroll_bar().page
	match section:
		"top":
			target_pos = 0
		"center":
			target_pos = viewport_height
		"bottom":
			target_pos = viewport_height * 2
	var tween = create_tween()
	tween.tween_property(
		scroll_container.get_v_scroll_bar(),
		"value",
		target_pos,
		0.3,
	). set_ease(Tween.EASE_IN_OUT)


func _on_play_pressed() -> void:
	scroll_to_section("top")
	$Sound/Button_Sound_1.play()

func _on_options_pressed() -> void:
	scroll_to_section("bottom")
	$Sound/Button_Sound_3.play()


func _input(event: InputEvent):
	if event.is_action_pressed("close"): get_tree().quit()


func _on_quit_pressed() -> void:
	$Sound/Button_Sound_2.play()
	get_tree().quit()

func _on_up_pressed() -> void:
	scroll_to_section("center")
	$Sound/Button_Sound_1.play()


func _on_down_pressed() -> void:
	scroll_to_section("center")
	$Sound/Button_Sound_3.play()


func _on_toggle_sound_pressed() -> void:
	sound_on = not sound_on
	if sound_on:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), false)
		$Sound/Button_Sound_1.play()
	else:
		AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), true)

func _on_resest_progress_pressed() -> void:
	GameState.reset_progress()
	get_tree().reload_current_scene()
