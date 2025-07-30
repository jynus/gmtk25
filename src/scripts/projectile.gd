extends Area2D

@export var SPEED: float = 200


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += scale.x * SPEED * delta
