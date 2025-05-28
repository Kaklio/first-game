class_name Blob

extends Node2D

enum TEAM {Gray, Blue, Pink, Red, Green}
enum CONTROLLER {Neutral, Player, AI}
#enum LEVEL {_1, _2, _3, _4, _5}

@export var Team: TEAM
@export var initial_count: int
var Controller: CONTROLLER
#@export var Level: LEVEL

const ANIMATIONS = {
	"0": "Gray_Animation",
	"1": "Blue_Animation",
	"2": "Pink_Animation",
	"3": "Red_Animation",
	"4": "Green_Animation",
}
const Frozen_Statuses: Array[String] = ["Frozen_1","Frozen_2","Frozen_3","Frozen_4","Frozen_5"]
const Infected_Statuses: Array[String] = ["Infected_1","Infected_2","Infected_3","Infected_4","Infected_5"]




# All Child Nodes REFRENCES
@onready var label: Label = $Label
@onready var timer: Timer = $Label/Timer
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var selected: TextureRect = $Selected
@onready var collisionZone: CollisionShape2D = $Area2D/CollisionShape2D
@onready var area: Area2D = $Area2D
@onready var Abilities = $Abilities
@onready var buttons = $Abilities

@onready var game = get_node("/root/Game")
static var mouse_over: bool = false
var click_pending := false
var double_click_threshold := 0.4
var last_click_time := 0.0

var count : int
var capacity : int = 10
var production_dealay : float = 2.3 # ACTUAL DELAY In Seconds, Lower delay means faster Production Rate
var coin_SPEED : int = 15
var defence : float = 1.0
var upgrade_threshold : int = 5

var Ability_Costs:= [5, 10, 10]

var is_Max_Level = false
var is_Infected = false
var base_Class = true
var is_Forzen = false
var has_Abilities = true
var producer_Unit = true

################                  ##################
################ DEFAULT FUCTIONS ##################
################                  ##################

# Runs When an Object is Created, Acts as a constructor
func _ready(): 
	label.text = str(count)
	timer.wait_time = production_dealay
	Controller = clamp(int(Team), 0, 2)
	if Controller == CONTROLLER.Neutral: capacity = 5
	count = initial_count
	count =  clamp(count, 0, capacity)
	if is_Forzen: sprite.play("Frozen")
	elif is_Infected: sprite.play("Infected")
	else: sprite.play(ANIMATIONS[str(Team)])

# Runs Every Frame
func _physics_process(delta: float):
	label.text = str(count)
	toggle_visual_indicators()



################                     ##################
################ INTERATIVE FUCTIONS ##################
################                     ##################

func _on_Clicked(viewport: Node, event: InputEvent, shape_idx: int):
	if event.is_action_pressed("left_click"):
		var current_time = Time.get_ticks_msec() / 1000.0
		if current_time - last_click_time < double_click_threshold:
			emit_signal("on_Double_Clicked", self)
		else: 
			emit_signal("on_Clicked", self)
		last_click_time = current_time




################                  ##################
################ PASSIVE FUCTIONS ##################
################                  ##################

func takeHit(coin: Coin, Sender: Blob):
	if Sender.Team == Team:
		count += coin.val
	else:
		count -= (coin.val/defence)
		$blob_Sounds/Take_Hit_Sound.play()
		if count < 0:
			emit_signal("converted", Sender, "")
	count =  clamp(count, 0, capacity)


func _on_mouse_entered() -> void:
	mouse_over = true

func _on_mouse_exited() -> void:
	mouse_over = false

func _on_timer_timeout():
	if not is_Forzen and producer_Unit:
		if not is_Infected:
			if count < capacity: # Generate Jelly or Goo Whatever you wanna call it :)
				count += 1
	if is_Infected:
		if count > 0:
			count -= 1
	ability_Available()


func toggle_visual_indicators():
	if count >= upgrade_threshold and Controller == CONTROLLER.Player and not is_Max_Level:
		toggleButtons(true)
	else: toggleButtons(false)
	if game.selected_blob == self and game.selected_blob.Controller == CONTROLLER.Player:
		selected.visible = true
	else: selected.visible = false

func setContoller()-> void:
	Controller = clamp(int(Team), 0, 2)


signal converted(converted_By: Blob, status: String) # Emit When A blob is converted
signal infected()
signal forzen()


func _on_converted(converted_By: Blob, status: String):
	count = abs(count)
	if converted_By:
		Team = converted_By.Team
		Controller = converted_By.Controller
		if status == "":
			$"blob_Sounds/Converted_Sound".play()
			is_Infected = false
			is_Forzen = false
	if base_Class: 
		if Controller != CONTROLLER.Neutral: capacity = 10
		if is_Forzen: sprite.play("Frozen")
		elif is_Infected: sprite.play("Infected")
		else: sprite.play(ANIMATIONS[str(Team)])

func ability_Available():
	if has_Abilities:
		var i:= 0
		for ability: TextureButton in Abilities.get_children():
			if count < Ability_Costs[i]:
				ability.disabled = true
			elif ability.disabled: 
				ability.disabled = false
				$blob_Sounds/UpgradeAvailable.play()
			i += 1

signal upgraded(blob: Blob, upgradeCode: String)
signal upgraded_To(upgraded_Blob: Blob)
signal on_Clicked(Clicked_Blob: Blob)
signal on_Double_Clicked(Clicked_Blob: Blob)

func _on_ability_1_pressed():
	emit_signal("upgraded", self, "Barrack")

func _on_ability_2_pressed():
	emit_signal("upgraded", self, "Fort")

func _on_ability_3_pressed():
	emit_signal("upgraded", self, "Artillery")


func toggleButtons(toggle: bool):
	buttons.visible = toggle


func _on_infected() -> void:
	is_Infected = true
	emit_signal("converted", null, "Infected")
	print("INFECTED")


func _on_forzen() -> void:
	is_Forzen = true
	Controller = CONTROLLER.Neutral
	Team = TEAM.Gray
	emit_signal("converted", null, "Frozen")
	print("FROZEN")
