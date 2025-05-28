class_name Barrack

extends Blob

enum LEVEL {_1, _2, _3, _4, _5}
@export var Level: LEVEL

# For Level 1 Barrack
var barrack_coin_SPEED = 20


const  ANIMATIONS_Barrack = {
	"0": ["Gray_1", "Gray_2", "Gray_3", "Gray_4", "Gray_5"],
	"1": ["Blue_1", "Blue_2", "Blue_3", "Blue_4", "Blue_5"],
	"2": ["Pink_1", "Pink_2", "Pink_3", "Pink_4", "Pink_5"],
	"3": ["Red_1", "Red_2", "Red_3", "Red_4", "Red_5"],
	"4": ["Green_1", "Green_2", "Green_3", "Green_4", "Green_5"],
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	coin_SPEED = barrack_coin_SPEED
	buttons = $upgrade
	Controller = clamp(int(Team), 0, 2)
	set_Stats()
	sprite.play(ANIMATIONS_Barrack[str(Team)][Level])
	base_Class = false
	count = initial_count
	count =  clamp(count, 0, capacity)
	has_Abilities = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_converted(converted_By: Blob, status: String):
	super(converted_By, status)
	if is_Forzen: sprite.play(Frozen_Statuses[Level])
	elif is_Infected: sprite.play(Infected_Statuses[Level])
	else: sprite.play(ANIMATIONS_Barrack[str(Team)][Level])




func set_Stats()-> void:
	match Level:
		0 :
			capacity = 10
			upgrade_threshold = 10
			timer.wait_time = 1.9
			collisionZone.scale = Vector2(1.0, 1.2)
			collisionZone.position = Vector2(0, 1)
			selected.position = Vector2(-13, -14)
		1 :
			capacity = 20
			upgrade_threshold = 15
			timer.wait_time = 1.6
			selected.position = Vector2(-13, -14)
			collisionZone.position = Vector2(1.0, 0.0)
			collisionZone.scale = Vector2(1.2, 1.2)
		2 :
			capacity = 30
			upgrade_threshold = 25
			timer.wait_time = 1.3
			selected.scale = Vector2(0.042, 0.042)
			selected.position = Vector2(-16, -20)
			collisionZone.position = Vector2(0.0, -3.0)
			collisionZone.scale = Vector2(1.4, 1.5)
		3 :
			capacity = 40
			upgrade_threshold = 35
			timer.wait_time = 1.1
			selected.scale = Vector2(0.042, 0.042)
			selected.position = Vector2(-16, -20)
			collisionZone.position = Vector2(0.0, -3.0)
			collisionZone.scale = Vector2(1.4, 1.6)
		4 :
			capacity = 50
			upgrade_threshold = 45
			timer.wait_time = 0.9
			selected.scale = Vector2(0.042, 0.042)
			selected.position = Vector2(-16, -20)
			collisionZone.position = Vector2(0.0, -5.0)
			collisionZone.scale = Vector2(1.5, 1.8)
	if Level >= 4 : is_Max_Level = true

func _on_upgrade_pressed() -> void:
	if not is_Max_Level:
		count -= upgrade_threshold
		Level += 1 
		set_Stats()
		$barrack_Sounds/Upgrading_Sound_1.play()
		sprite.play(ANIMATIONS_Barrack[str(Team)][Level])
		if Level >= 4:
			is_Max_Level = true
