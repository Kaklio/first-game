class_name Fort

extends Blob

enum LEVEL {_1, _2, _3}
@export var Level: LEVEL

var BulletScene = preload("res://Scenes/Bullet.tscn")

# For Level 1 Fort
var Fort_coin_SPEED = 10
var target_coin: Coin = null
var Fire_Rate_Delay = 0.6 # After How many secons the Target Bubble's Value is Decreased
var Fire_Power = 1
var targets_In_Range: Array[Coin]
@onready var Firing_Timer: Timer = $RangeArea/Firing_Delay
@onready var defence_Zone: CollisionShape2D = $RangeArea/CollisionShape2D
@onready var defence_Zone_Texture: TextureRect = $RangeArea/TextureRect


const  ANIMATIONS_Fort = {
	"0": ["Gray_Fort_1", "Gray_Fort_2", "Gray_Fort_3"],
	"1": ["Blue_Fort_1", "Blue_Fort_2", "Blue_Fort_3"],
	"2": ["Pink_Fort_1", "Pink_Fort_2", "Pink_Fort_3"],
	"3": ["Red_Fort_1", "Red_Fort_2", "Red_Fort_3"],
	"4": ["Green_Fort_1", "Green_Fort_2", "Green_Fort_3"],
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	producer_Unit = false
	coin_SPEED = Fort_coin_SPEED
	buttons = $upgrade
	base_Class = false
	Controller = clamp(int(Team), 0, 2)
	set_Stats()
	sprite.play(ANIMATIONS_Fort[str(Team)][Level])
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
	else: sprite.play(ANIMATIONS_Fort[str(Team)][Level])

func _on_range_area_body_entered(body: Node2D) -> void:
	if body is Coin:
		if body.Team != Team:
			target_coin = body
			targets_In_Range.append(target_coin)
			if not target_coin.is_connected("poped", target_Coin_Poped):
				target_coin.poped.connect(target_Coin_Poped)

func _on_range_area_body_exited(body: Node2D) -> void:
	if target_coin != null:
		targets_In_Range.erase(body)
		if target_coin.is_connected("poped", target_Coin_Poped): target_coin.poped.disconnect(target_Coin_Poped)
		if targets_In_Range.is_empty(): target_coin = null
		else: target_coin = targets_In_Range[0]

func _on_firing_delay_timeout():
	if target_coin != null and not is_Forzen:
		var bullet = BulletScene.instantiate()
		bullet.global_position = global_position
		bullet.target_position = target_coin.global_position
		get_tree().current_scene.add_child(bullet)  # Add to the main scene
		target_coin.val -= Fire_Power
		$fort_Sounds/Fire_Sound.play()

func set_Stats()-> void:
	match Level:
		0 :
			capacity = 40
			upgrade_threshold = 30
			defence = 2
			Fire_Power = 1
			Firing_Timer.wait_time = 1
			selected.position = Vector2(-13, -7)
			defence_Zone_Texture.position = Vector2(-36, -37)
		1 :
			capacity = 70
			upgrade_threshold = 50
			defence = 3
			Fire_Power = 2
			Firing_Timer.wait_time = 0.7
			defence_Zone_Texture.scale = Vector2(0.201, 0.201)
			defence_Zone_Texture.position = Vector2(-44, -45)
			defence_Zone.scale = Vector2(1.3, 1.3)
			selected.position = Vector2(-16, -9)
			selected.scale = Vector2(0.043, 0.043)
		2 :
			capacity = 100
			upgrade_threshold = 70
			defence = 4
			Fire_Power = 3
			Firing_Timer.wait_time = 0.4
			defence_Zone_Texture.scale = Vector2(0.258, 0.254)
			defence_Zone_Texture.position = Vector2(-57, -57)
			defence_Zone.scale = Vector2(1.6, 1.6)
			selected.scale = Vector2(0.045, 0.045)
			selected.position = Vector2(-17, -13)
			collisionZone.position += Vector2(0.0, -4.5)
			collisionZone.scale = Vector2(1.2, 1.4)
	if Level >= 2 : is_Max_Level = true

func _on_upgrade_pressed():
	if not is_Max_Level:
		count -= upgrade_threshold
		Level += 1
		set_Stats()
		$fort_Sounds/Upgrading_Sound_2.play()
		sprite.play(ANIMATIONS_Fort[str(Team)][Level])
		if Level >= 2:
			is_Max_Level = true

func target_Coin_Poped(poped_Coin: Coin)-> void:
	$fort_Sounds/Poping_Sound.play()
	targets_In_Range.erase(poped_Coin)
	if targets_In_Range.is_empty(): target_coin = null
	else: target_coin = targets_In_Range[0]
