class_name Artillery

extends Blob

enum LEVEL {_1, _2, _3}
@export var Level: LEVEL

# For Level 1 Artillery
var Artillery_coin_SPEED = 25


@onready var ChargeBar: TextureProgressBar = $ChargeBar
@onready var chargeTimer: Timer = $ChargeBar/ChargeTime
var timer_duration := 0.0
var time_passed := 0.0
var charging := false

var Ability_Charged: bool = false
var Ability_Name: String = ""
var Ability_Dict = {
	"Infect": 30,
	"Freeze": 45,
	"Capture": 60,
}

const  ANIMATIONS_Artillery = {
	"0": ["Gray_Artillery_1", "Gray_Artillery_2", "Gray_Artillery_3"],
	"1": ["Blue_Artillery_1", "Blue_Artillery_2", "Blue_Artillery_3"],
	"2": ["Pink_Artillery_1", "Pink_Artillery_2", "Pink_Artillery_3"],
	"3": ["Red_Artillery_1", "Red_Artillery_2", "Red_Artillery_3"],
	"4": ["Green_Artillery_1", "Green_Artillery_2", "Green_Artillery_3"],
}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	producer_Unit = false
	coin_SPEED = Artillery_coin_SPEED
	buttons = $upgrade
	Controller = clamp(int(Team), 0, 2)
	set_Stats()
	sprite.play(ANIMATIONS_Artillery[str(Team)][Level])
	base_Class = false
	var i:= 0
	for costs in Ability_Dict:
		Ability_Costs[i] = Ability_Dict[costs]
		i += 1
	count = initial_count
	count =  clamp(count, 0, capacity)
	has_Abilities = true

func _on_upgrade_pressed():
	if not is_Max_Level:
		count -= upgrade_threshold
		Level += 1
		set_Stats()
		$artillery_Sounds/Upgrading_Sound_2.play()
		sprite.play(ANIMATIONS_Artillery[str(Team)][Level])
		if Level >= 2:
			is_Max_Level = true

func _on_converted(converted_By: Blob, status: String):
	super(converted_By, status)
	if is_Forzen: sprite.play(Frozen_Statuses[Level])
	elif is_Infected: sprite.play(Infected_Statuses[Level])
	else: sprite.play(ANIMATIONS_Artillery[str(Team)][Level])


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if charging:
		time_passed += delta
		var progress = clamp((time_passed / timer_duration) * ChargeBar.max_value, 0, ChargeBar.max_value)
		ChargeBar.value = progress
		if count < Ability_Dict[Ability_Name]:
			cancel_Charging()

func _on_ability_1_pressed():
	if Ability_Name != "Infect":
		print("Infecting")
		initiate_Charging("Infect")
		$artillery_Sounds/Charging.play()
	else: cancel_Charging()

func _on_ability_2_pressed():
	if Ability_Name != "Freeze":
		print("Freezing")
		initiate_Charging("Freeze")
		$artillery_Sounds/Charging.play()
	else: cancel_Charging()

func _on_ability_3_pressed():
	if Ability_Name != "Capture":
		print("Capturing")
		initiate_Charging("Capture")
		$artillery_Sounds/Charging.play()
	else: cancel_Charging()

func set_Stats()-> void:
	match Level:
		0 :
			capacity = 40
			upgrade_threshold = 30
		1 :
			capacity = 70
			upgrade_threshold = 50
			selected.scale = Vector2(0.04, 0.04)
			selected.position = Vector2(-15, -17)
			collisionZone.position = Vector2(0.0, -2.0)
			collisionZone.scale = Vector2(1.4, 1.1)
		2 :
			capacity = 100
			upgrade_threshold = 70
			selected.scale = Vector2(0.043, 0.043)
			selected.position = Vector2(-16, -18)
			collisionZone.position = Vector2(0.0, -3.0)
			collisionZone.scale = Vector2(1.6, 1.4)
	if Level >= 2 : is_Max_Level = true

func initiate_Charging(ability_name: String):
		if count >= Ability_Dict[ability_name]:
			Ability_Name = ability_name
			start_Charging(float(Ability_Dict[Ability_Name]))
			ChargeBar.visible = true

func cancel_Charging():
	ChargeBar.value = 0
	charging = false
	chargeTimer.stop()
	ability_Fired()
	if $artillery_Sounds/Charging.playing: $artillery_Sounds/Charging.stop()
	elif $artillery_Sounds/ChargingLoop.playing: $artillery_Sounds/ChargingLoop.stop()
	print("Charge Canceled!!")

func _on_selected() -> void:
	Abilities.visible = true
	var Abibility_Buttons := Abilities.get_children()
	for i in range(Level+1):
		Abibility_Buttons[i].visible = true
		pass

func _on_deselected() -> void:
	Abilities.visible = false
	var Abibility_Buttons := Abilities.get_children()
	for i in range(Level+1):
		Abibility_Buttons[i].visible = false

func toggleButtons(toggle: bool):
	$upgrade.visible = toggle


func start_Charging(duration: float):
	timer_duration = duration
	time_passed = 0.0
	ChargeBar.value = 0
	charging = true
	chargeTimer.start(duration)

func ability_Fired():
	ChargeBar.visible = false
	Ability_Charged = false
	Ability_Name = ""

signal Ability_Convert(target: Blob)
signal Ability_Infect(target: Blob)
signal Ability_Freeze(target: Blob)
signal ready_To_Fire(shooter: Artillery)

func _on_charge_time_timeout() -> void:
	charging = false
	ChargeBar.value = ChargeBar.max_value
	Ability_Charged = true
	$artillery_Sounds/ChargingLoop.stop()
	$artillery_Sounds/Charging_Complete_Sound.play()
	emit_signal("ready_To_Fire", self)
	print("READY TO FIRE!!")

func visualize_Beam(from: Vector2, to: Vector2, color: Color):
	var beam = Line2D.new()
	beam.width = 4
	beam.default_color = color
	beam.points = [from, to]
	game.add_child(beam)

	# Optionally remove after 0.2 seconds
	await get_tree().create_timer(0.4).timeout
	beam.queue_free()

func _on_ability_convert(target: Blob) -> void:
	target.emit_signal("converted", self, "")
	count -= Ability_Dict["Capture"]
	$artillery_Sounds/Ability_Convert_Sound.play()
	visualize_Beam(self.global_position, target.global_position, Color.RED)

func _on_ability_freeze(target: Blob) -> void:
	target.emit_signal("forzen")
	$artillery_Sounds/Ability_Freeze_Sound.play()
	count -= Ability_Dict["Freeze"]
	visualize_Beam(self.global_position, target.global_position, Color.BLUE)

func _on_ability_infect(target: Blob) -> void:
	target.emit_signal("infected")
	count -= Ability_Dict["Infect"]
	$artillery_Sounds/Ability_Infect_Sound.play()
	visualize_Beam(self.global_position, target.global_position, Color.GREEN)

func _on_charging_start_sound_finished() -> void:
	if charging: $artillery_Sounds/ChargingLoop.play()
