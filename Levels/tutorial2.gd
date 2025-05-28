extends Node2D


@onready var tap_Hand : AnimatedSprite2D = $AnimatedSprite2D
@onready var BlackBG : ColorRect = $ColorRect
@onready var Tutorial_text: Label = $Label
var loop:= false
var turn:= 1
var coin_scene = preload("res://Scenes/Coin.tscn")
func makeCoin(from_blob: Blob) -> Coin:
	var coin_instance: Coin = coin_scene.instantiate()
	if coin_instance == null:
		print("ERROR: Coin failed to instantiate")
	coin_instance.Team = from_blob.Team
	coin_instance.SPEED = from_blob.coin_SPEED
	add_child(coin_instance)
	coin_instance.global_position = from_blob.global_position
	return coin_instance
# Called when the node enters the scene tree for the first time.
func launch_coin(from_blob: Blob, to_blob: Blob):
	# Get the Coin node from the sender Blob
	if from_blob.count>0:
		var coin: Coin = makeCoin(from_blob)
		coin.setTarget(to_blob, from_blob)
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(2).timeout #Get List of All Blobs, excluding self
	launch_coin($"../blobs/Enemy_Barrack", $"../blobs/Blob")
	await get_tree().create_timer(2).timeout #Get List of All Blobs, excluding self
	Engine.time_scale = 0
	$Timer.start()
	BlackBG.visible = true
	Tutorial_text.visible = true
	Tutorial_text.text = "Tutorial
The Pink Slime is 
Targeting Your Blob!"
	await get_tree().create_timer(3).timeout #Get List of All Blobs, excluding self
	BlackBG.visible = false
	Tutorial_text.visible = false
	await get_tree().create_timer(3).timeout #Get List of All Blobs, excluding self
	tap_Hand.visible = false
	$AnimationPlayer.stop()
	tap_Hand.stop()
	tap_Hand.play("default")
	$Timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timer_timeout() -> void:
	match  turn:
		1:
			Engine.time_scale = 1
			$AnimationPlayer.play("Move_Hand")
			tap_Hand.visible = true
			tap_Hand.play("default")
			Tutorial_text.text = "Tutorial
Tip: Send Slime to your Blob to 
Reinforce it or it will be Captured!"
			$Timer.stop()
			$Timer.wait_time = 10
			turn += 1
		2:
			BlackBG.visible = true
			Tutorial_text.visible = true
			Tutorial_text.text = "Tutorial
Tip: Now Capture the Pink Slime"
			$Timer.wait_time = 5
			$Timer.start()
			turn += 1
		3:
			BlackBG.visible = false
			Tutorial_text.visible = false
			$Timer.wait_time = 10
			$Timer.start()
			turn -= 1
