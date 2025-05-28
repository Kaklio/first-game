extends Node2D

var selected_blob: Blob = null
var coin_scene = preload("res://Scenes/Coin.tscn")
var barrack_instance = preload("res://Scenes/barrack.tscn")
var artillery_instance = preload("res://Scenes/Artillery.tscn")
var fort_instance = preload("res://Scenes/Fort.tscn")

@onready var all_blobs: Array = get_node("blobs").get_children()
@onready var pause_Button: TextureButton = $Pause_Button
@onready var Pause_Menu: Control = $Pause
@onready var Next_Level_Screen: Control = $Next_Lvl_Srceen
@onready var level_Failed_Screen: Control = $Lost_Screen
@onready var all_Game_Menus: Array[Control] = [$Pause, $Next_Lvl_Srceen, $Lost_Screen]

var total_Count: int = 0

var win_condition: Callable
var lose_condition: Callable
var level_Number: int

var level_Completed: bool = false
var level_Lost: bool = false
var is_AI_Defeated: bool = false
var has_AI_Won: bool = false


var level_path: String

func makeCoin(from_blob: Blob) -> Coin:
	var coin_instance: Coin = coin_scene.instantiate()
	coin_instance.Team = from_blob.Team
	coin_instance.SPEED = from_blob.coin_SPEED
	add_child(coin_instance)
	coin_instance.global_position = from_blob.global_position
	return coin_instance
# Called when the node enters the scene tree for the first time.

func upgrade_blob(blob: Blob, upgradeCode: String):
	var upgraded_blob
	match upgradeCode:
		"Barrack": upgraded_blob = barrack_instance.instantiate()
		"Fort": upgraded_blob = fort_instance.instantiate()
		"Artillery": upgraded_blob = artillery_instance.instantiate()
	upgraded_blob.global_position = blob.global_position
	upgraded_blob.rotation = blob.rotation
	get_node("blobs").add_child(upgraded_blob)
	all_blobs.erase(blob)
	all_blobs.append(upgraded_blob)
	upgraded_blob.upgraded.connect(upgrade_blob)
	upgraded_blob.on_Clicked.connect(handle_Blob_Interaction)
	blob.emit_signal("upgraded_To", upgraded_blob)
	upgraded_blob.emit_signal("converted", blob, "") # false for frozen
	blob.emit_signal("converted", upgraded_blob, "") # false for frozen
	if chance(50): $Sounds/Upgrading_Sound_1.play()
	else: $Sounds/Upgrading_Sound_2.play()
	blob.queue_free()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	win_Lose_Conditons()
	for blob: Blob in all_blobs:
		blob.upgraded.connect(upgrade_blob)
		blob.on_Clicked.connect(handle_Blob_Interaction)
	Pause_Menu.resume.connect(resume)
	Next_Level_Screen.next_level.connect(load_Next_Level)
	for menu: Control in all_Game_Menus:
		menu.quit.connect(quit)
		menu.main_Menu.connect(main_Menu)
		menu.restart.connect(restart)

signal level_Cleared(level_No: int)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float):
	if not level_Completed and win_condition.call():
		print("Level ",level_Number, " Complete!",)
		GameState.unlock_level(level_Number + 1)
		emit_signal("level_Cleared", level_Number)
		$Sounds/Level_Cleared_Sound.play()
		Next_Level_Screen.visible = true
		$Sounds/Level_Theme.stop()
		Engine.time_scale = 0
		level_Completed = true
	if not level_Lost and lose_condition.call(): 
		$Sounds/Level_Theme.stop()
		level_Failed_Screen.visible = true
		$Sounds/Losing_Sound.play()
		level_Lost = true
		Engine.time_scale = 0

func win_Lose_Conditons()-> void:
	level_path = get_tree().current_scene.scene_file_path
	var parts = level_path.split("_")  # ["res://Levels/level", "3.tscn"]
	var num_with_ext = parts[1]        # "3.tscn"
	level_Number = int(num_with_ext.get_basename().get_file().get_basename())
	
	match level_Number:
		1:
			win_condition = func(): return $blobs/Blob.Controller == Blob.CONTROLLER.Player
			lose_condition = func(): return $blobs/Barrack.Controller != Blob.CONTROLLER.Player
		2:
			win_condition = func(): return $blobs/Enemy_Barrack.Controller == Blob.CONTROLLER.Player
			lose_condition = func(): return $blobs/Blob.Controller != Blob.CONTROLLER.Player
		3:
			win_condition = func(): return $blobs/Enemy_Barrack.Controller == Blob.CONTROLLER.Player
			lose_condition = func(): return $blobs/Barrack.Controller != Blob.CONTROLLER.Player
		_:
			$AI.Level_Cleared.connect(AI_Defeated)
			$AI.Level_Lost.connect(AI_Won)
			win_condition = func(): return is_AI_Defeated
			lose_condition = func(): return has_AI_Won

func AI_Defeated()-> void:
	is_AI_Defeated = true

func AI_Won()-> void:
	has_AI_Won = true

func chance(percent: float) -> bool:
	return randf() * 100 < percent

func _input(event: InputEvent):
	if event.is_action_pressed("left_click"):
		if not Blob.mouse_over and selected_blob != null:
			selected_blob = null
	elif event.is_action_pressed("close"): get_tree().quit()

func launch_coin(from_blob: Blob, to_blob: Blob):
	# Get the Coin node from the sender Blob
	if from_blob.count>0:
		var coin: Coin = makeCoin(from_blob)
		coin.setTarget(to_blob, from_blob)

func handle_Blob_Interaction(Clicked_Blob: Blob):
	if selected_blob == null:
		if  Clicked_Blob.Controller == Blob.CONTROLLER.Player:
			selected_blob = Clicked_Blob
	elif selected_blob == Clicked_Blob: selected_blob = null
	else:
		if selected_blob is Artillery and selected_blob.Controller == 1:
			if selected_blob.Ability_Charged:
				match selected_blob.Ability_Name:
					"Capture":
						selected_blob.emit_signal("Ability_Convert", Clicked_Blob)
					"Freeze":
						selected_blob.emit_signal("Ability_Freeze", Clicked_Blob)
					"Infect":
						selected_blob.emit_signal("Ability_Infect", Clicked_Blob)
				selected_blob.ability_Fired()
			elif selected_blob.charging: selected_blob = null
			else: 
				launch_coin(selected_blob, Clicked_Blob)
				if chance(50): $Sounds/Sending_Sound_1.play()
				else: $Sounds/Sending_Sound_2.play()
		else: 
			launch_coin(selected_blob, Clicked_Blob)
			if chance(50): $Sounds/Sending_Sound_1.play()
			else: $Sounds/Sending_Sound_2.play()
		selected_blob = null

func _on_timer_timeout() -> void:
	total_Count = 0
	for blob in all_blobs:
		total_Count += blob.count
	if chance (1): $Sounds/Sneeze_Sound.play()

func toggle_pause()-> void:
	Pause_Menu.visible = not Pause_Menu.visible
	Engine.time_scale = int(not Pause_Menu.visible)

func _on_pause_button_pressed() -> void:
	toggle_pause()

func resume()-> void:
	toggle_pause()

func restart()-> void:
	Engine.time_scale = 1
	get_tree().reload_current_scene()

func main_Menu()-> void:
	Engine.time_scale = 1
	get_tree().change_scene_to_file("res://Scenes/Menu.tscn")

func quit()-> void:
	get_tree().quit()

func load_Next_Level()-> void:
	Engine.time_scale = 1
	get_tree().change_scene_to_file("res://Levels/level_"+str(level_Number+1)+".tscn")
