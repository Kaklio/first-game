extends Sprite2D


var speed := 150.0
var target_position: Vector2

func _ready():
	look_at(target_position)

func _process(delta):
	var direction = (target_position - global_position).normalized()
	global_position += direction * speed * delta

	if global_position.distance_to(target_position) < 3:
		queue_free()  # Reached target
