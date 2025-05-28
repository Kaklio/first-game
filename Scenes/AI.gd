class_name AI

extends Node

@onready var game = get_node("/root/Game")
var coin_scene = preload("res://Scenes/Coin.tscn")
@onready var process_delay: Timer = $Timer
var delay_time:= 2.0
var AI_Won : bool = false
var AI_Lost: bool = false

@onready var blobs_list
@onready var AI_blobs: Array

var Team_Artillery = {
	"0": false,
	"1": false,
	"2": false,
	"3": false,
	"4": false,
}

# Called when the node enters the scene tree for the first time.
func _ready():
	process_delay.wait_time = delay_time
	await get_tree().create_timer(0.5).timeout #Get List of All Blobs, excluding self
	blobs_list = game.all_blobs
	AI_blobs = game.all_blobs.filter(func(b: Blob): return b.Controller == Blob.CONTROLLER.AI)
	check_for_Artillery()
	process_delay.start()
	
	for blob: Blob in game.all_blobs:
		blob.converted.connect(_on_any_blob_converted)
#		if blob.base_Class: blob.upgraded_To.connect(_on_any_blob_converted)

signal Level_Cleared
signal Level_Lost

func makeCoin(from_blob: Blob) -> CharacterBody2D:
	var coin_instance: Coin = coin_scene.instantiate()
	coin_instance.Team = from_blob.Team
	coin_instance.SPEED = from_blob.coin_SPEED
	add_child(coin_instance)
	coin_instance.global_position = from_blob.global_position
	return coin_instance

func get_allies(blob: Blob) -> Array:
	return game.all_blobs.filter(func(b: Blob): return b.Team == blob.Team and b != blob)
func get_enemies(blob: Blob) -> Array:
	var enemy_List: Array = game.all_blobs.filter(func(b: Blob): return b.Team != blob.Team)
	return enemy_List

func percent_of(number: float, percent: float) -> float:
	return (percent / number) * 100
func chance(percent: float) -> bool:
	return randf() * 100 < percent
func get_random_blob(arr: Array):
	if arr.is_empty():
		return null
	return arr[randi() % arr.size()]
func get_Highest_Count_Blob(arr: Array)-> Blob:
	if arr.is_empty():
		return null
	var max_Blob : Blob
	max_Blob = arr[0]
	for blob in arr:
		if blob.count > max_Blob.count:
			max_Blob = blob
	return max_Blob
func get_Lowest_Count_Blob(arr: Array)-> Blob:
	if arr.is_empty():
		return null
	var min_Blob : Blob
	min_Blob = arr[0]
	for blob in arr:
		if blob.count < min_Blob.count:
			min_Blob = blob
	return min_Blob
func difference(num1: int, num2: int)-> int:
	return abs(num1-num2)



func chooseTarget(arr: Array, sender: Blob) -> Blob:
	if arr.is_empty():
		return null
	# Sort blobs by distance to sender (ascending)
	arr.sort_custom(func(a: Blob, b: Blob) -> bool:
		return sender.global_position.distance_to(a.global_position) < sender.global_position.distance_to(b.global_position)
	)
	
	#for blob: Blob in arr:
		#print(abs(blob.global_position - sender.global_position))
	#
	# Assign weights: closest = highest weight
	var weights := []
	var total := 0.0
	for i in range(arr.size()):
		var weight = 1.0 / pow(i + 1, 4) # Closest gets weight 1.0, then 0.5, 0.33, ...
		weights.append(weight)
		total += weight
	# Randomly choose based on weights
	var rand := randf() * total
	var accum := 0.0
	for i in range(arr.size()):
		accum += weights[i]
		if rand <= accum:
			return arr[i]
	return arr[-1] # fallback
func choose_Support_Target(arr: Array, sender: Blob) -> Blob:
	if arr.is_empty():
		return null
	if Team_Artillery[str(sender.Team)]:
		for artillery in arr:
			if artillery is Artillery: 
				if artillery.count < artillery.capacity: return artillery
		return get_random_blob(arr)
	else: return get_Lowest_Count_Blob(arr)


func is_upgrade_Decided(blob: Blob)-> bool:
	if blob.is_Max_Level: return false
	
	if blob.base_Class and blob.count >= blob.upgrade_threshold:
		print("TRING UP BLOB")
		return chance(30 + (difference(blob.count, blob.upgrade_threshold) * 10))
	elif not blob.base_Class and blob.count >= blob.upgrade_threshold:
		if blob is Artillery:
			if blob.charging: 
				return false
		return chance((blob.LEVEL.size()/(blob.Level + 1)) * 10)
	else: return false
func is_sending_Decided(sender: Blob)-> bool:
	return chance(percent_of(sender.capacity, sender.count) / 2.0)
func decide_action(blob: Blob)-> bool:
	var barrack_count := 0
	var has_Artilley = false
	for ally in get_allies(blob):
		if ally is Barrack: barrack_count += 1
	if barrack_count >= 3 and Team_Artillery[str(blob.Team)]:
		if blob is Artillery: return chance(10)
		else: return chance(80)
	elif barrack_count >= 3: return chance(50)
	else: return chance(10)


func _on_any_blob_converted(_converted_by: Blob, status: String):
	AI_blobs = game.all_blobs.filter(func(b: Blob): return b.Controller == Blob.CONTROLLER.AI)
	check_for_Artillery()
	for blob: Blob in game.all_blobs:
		if not blob.is_connected("converted", _on_any_blob_converted):
			blob.converted.connect(_on_any_blob_converted)
	
	if AI_blobs.size() <= 0: 
		AI_Lost = true
		emit_signal("Level_Cleared")
		print("AI_Lost")
	var player_blobs = game.all_blobs.filter(func(b: Blob): return b.Controller == Blob.CONTROLLER.Player)
	if player_blobs.size() <= 0:
		print("AI WON")
		emit_signal("Level_Lost")
		AI_Won = true


func check_for_Artillery()-> void:
	for Team in Team_Artillery:
		Team = false
	
	for blob in AI_blobs:
		if blob is Artillery : Team_Artillery[str(blob.Team)] = true
func fire_AI_Artillery(shooter: Artillery)-> void:
	print("Firing Signal Catched")
	var target: Blob = get_Highest_Count_Blob(get_enemies(shooter))
	if target != null:
		match shooter.Ability_Name:
			"Capture":
				shooter.emit_signal("Ability_Convert", target)
			"Freeze":
				shooter.emit_signal("Ability_Freeze", target)
			"Infect":
				shooter.emit_signal("Ability_Infect", target)


func attack(coin: Coin, sender: Blob):
	if sender is Barrack:
		coin.setTarget(chooseTarget(get_enemies(sender), sender), sender)
	elif sender is Artillery:
		var i := 0
		for ability: TextureButton in sender.Abilities.get_children():
			if ability.disabled == false: i += 1
		if i > 0 and not sender.charging:
			sender.call("_on_ability_"+str(i)+"_pressed")
			if not sender.is_connected("ready_To_Fire", fire_AI_Artillery):
				print("CHARGING...", sender.charging)
				sender.ready_To_Fire.connect(fire_AI_Artillery)
func support(coin: Coin, sender: Blob):
	if sender is Barrack:
		coin.setTarget(choose_Support_Target(get_allies(sender), sender), sender)
func upgrade_Blob(blob: Blob):
	if blob.base_Class:
		print("U{GRADE BLOB PLAESE}")
		if chance(80):
			blob._on_ability_1_pressed()
		elif chance(60):
			blob._on_ability_3_pressed()
		else: blob._on_ability_2_pressed()
	else:
		blob._on_upgrade_pressed()


func _on_timer_timeout() -> void:
	if not AI_Won and not AI_Lost: for AI_blob: Blob in AI_blobs: 
		if AI_blob.base_Class:
			if is_upgrade_Decided(AI_blob):
				upgrade_Blob(AI_blob)
		else:
			if is_upgrade_Decided(AI_blob):
				upgrade_Blob(AI_blob)
			else:
				if is_sending_Decided(AI_blob):
					var coin: Coin = makeCoin(AI_blob)
					if decide_action(AI_blob):                           
						support(coin, AI_blob)
					else: attack(coin, AI_blob)
