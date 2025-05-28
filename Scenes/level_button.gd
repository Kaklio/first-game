class_name level_button

extends TextureButton

@export var number: int = 1
@onready var number_Label: Label = $Number

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#await get_tree().create_timer(0.1).timeout #Get List of All Blobs, excluding self
	number_Label.text = str(number)
	set_meta("level_path", "res://Levels/level_"+str(number)+".tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if disabled: number_Label.visible = false
	else: number_Label.visible = true
