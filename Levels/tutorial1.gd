extends Node2D

@onready var tap_Hand : AnimatedSprite2D = $AnimatedSprite2D
@onready var BlackBG : ColorRect = $ColorRect
@onready var Tutorial_text: Label = $Label
var loop = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(1).timeout #Get List of All Blobs, excluding self
	$AnimationPlayer.play("Move_Hand")
	tap_Hand.visible = true
	tap_Hand.play("default")
	BlackBG.visible = true
	Tutorial_text.visible = true
	$Goal.visible = true
	Tutorial_text.text = "Tutorial
Tip: Tap on the Blue slime to Select it"
	await get_tree().create_timer(3).timeout #Get List of All Blobs, excluding self
	tap_Hand.stop()
	BlackBG.visible = false
	Tutorial_text.visible = false
	await get_tree().create_timer(2).timeout #Get List of All Blobs, excluding self
	tap_Hand.play("default")
	BlackBG.visible = true
	Tutorial_text.visible = true
	Tutorial_text.text = "Tutorial
Tip: Tap on the Grey Blob to Send Slime
(Double Tap To send all your the Slime)"
	await get_tree().create_timer(5).timeout #Get List of All Blobs, excluding self
	$AnimationPlayer.stop()
	tap_Hand.visible = false
	tap_Hand.stop()
	BlackBG.visible = false
	Tutorial_text.visible = false
	$Timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_timer_timeout() -> void:
	$AnimationPlayer.play("Move_Hand")
	tap_Hand.visible = true
	tap_Hand.play("default")
	BlackBG.visible = true
	Tutorial_text.visible = true
	Tutorial_text.text = "Tutorial
Tip: Tap on the Blue slime to Select it"
	await get_tree().create_timer(3).timeout #Get List of All Blobs, excluding self
	tap_Hand.stop()
	BlackBG.visible = false
	Tutorial_text.visible = false
	await get_tree().create_timer(2).timeout #Get List of All Blobs, excluding self
	tap_Hand.play("default")
	BlackBG.visible = true
	Tutorial_text.visible = true
	Tutorial_text.text = "Tutorial
Tip: Tap on the Grey Blob to Send Slime
(Double Tap To send all your the Slime)"
	await get_tree().create_timer(5).timeout #Get List of All Blobs, excluding self
	$AnimationPlayer.stop()
	tap_Hand.visible = false
	tap_Hand.stop()
	BlackBG.visible = false
	Tutorial_text.visible = false
	$Timer.start()
