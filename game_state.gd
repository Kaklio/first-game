extends Node

signal level_unlocked(level: int)

var unlocked_levels: Array = [1] # Level 1 is unlocked by default

var save_path := "user://save_game.cfg"

func _ready() -> void:
	load_progress()

func unlock_level(level: int) -> void:
	if not unlocked_levels.has(level):
		unlocked_levels.append(level)
		unlocked_levels.sort()
		save_progress()
		emit_signal("level_unlocked", level)

func save_progress() -> void:
	var config := ConfigFile.new()
	config.set_value("progress", "unlocked_levels", unlocked_levels)
	var err = config.save(save_path)
	if err != OK:
		print("Failed to save progress: ", err)

func load_progress() -> void:
	var config := ConfigFile.new()
	var err = config.load(save_path)
	if err == OK:
		unlocked_levels = config.get_value("progress", "unlocked_levels", [1])
	else:
		print("No save file found, starting fresh.")

func reset_progress():
	unlocked_levels = [1]
	var config = ConfigFile.new()
	var err = config.save(save_path)
	if err != OK:
		print("Failed to reset save: ", err)
