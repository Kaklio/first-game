class_name Coin

extends CharacterBody2D

@onready var target: Blob
@onready var sender: Blob
@onready var val: int
@onready var Team: Blob.TEAM
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var nav_agent : NavigationAgent2D = $Navigation/NavigationAgent2D
@onready var label: Label = $Label
@onready var double_Click_Timer = $Double_Click_Timer

@export var SPEED = 50.0
var awaiting_Double_Click = false


const Colors = {
	"0": "gray",
	"1": "blue",
	"2": "pink",
	"3": "red",
	"4": "green",
	}

signal poped(poped_Coin: Coin)

################                  ##################
################ DEFAULT FUCTIONS ##################
################                  ##################

func _ready():
	sprite.play(Colors[str(Team)])	


func _physics_process(delta: float) :
	
	label.text = str(val)
	
	var direction = Vector2.ZERO
	
	direction = nav_agent.get_next_path_position() - global_position
	direction = direction.normalized()
	
	
	velocity = direction * SPEED
	move_and_slide()
	
	if nav_agent.is_target_reached() and target != null:
		target.takeHit(self, sender)
		queue_free()
	if val <= 0: 
		emit_signal("poped", self)
		queue_free()


################                  ##################
################ ACTIVE FUCTIONS ##################
################                  ##################

func setTarget(TARGET: Blob, SENDER: Blob):
	if TARGET == null: 
		queue_free()
		return
	
	target = TARGET
	sender = SENDER
	val = SENDER.count/2
	label.text = str(val) 
	SENDER.count /= 2
	
	target.on_Double_Clicked.connect(target_Double_Clicked)
	awaiting_Double_Click = true
	double_Click_Timer.start()
	target.upgraded_To.connect(change_Target)


################                  ##################
################ PASSIVE FUCTIONS ##################
################                  ##################

func target_Double_Clicked(Clicked_Blob: Blob):
	val += sender.count
	sender.count = 0
	label.text = str(val)

func change_Target(upgraded_blob):
	setTarget(upgraded_blob, sender)

func _on_timer_timeout() -> void:
	
	if target != null:
		nav_agent.target_position = target.global_position


func _on_double_click_timer_timeout() -> void:
	awaiting_Double_Click = false
	target.on_Double_Clicked.disconnect(target_Double_Clicked)
