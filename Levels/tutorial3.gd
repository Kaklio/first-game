extends Node2D

@onready var info_Btn = $Info_Screen_Btn
@onready var red_Arrow : AnimatedSprite2D = $AnimatedSprite2D
@onready var BlackBG : ColorRect = $ColorRect
@onready var Tutorial_text: Label = $Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await get_tree().create_timer(4).timeout #Get List of All Blobs, excluding self
	BlackBG.visible = true
	Tutorial_text.visible = true
	Tutorial_text.text = "Tutorial
Tip: Bypass the Forts by upgrading your
blob to an Artillery"
	await get_tree().create_timer(6).timeout #Get List of All Blobs, excluding self
	red_Arrow.visible = true
	Tutorial_text.text = "Tutorial
Tip: Click the '?' Button to get the all
the details"
	await get_tree().create_timer(5).timeout #Get List of All Blobs, excluding self
	BlackBG.visible = false
	Tutorial_text.visible = false
	red_Arrow.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_info_screen_btn_pressed() -> void:
	$Info_Screen.visible = not $Info_Screen.visible
