extends Area2D

@export var speed: float = 200
@export var damage: float = 10

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += scale.x * speed * delta


func _on_body_entered(_body: Node2D) -> void:
	# Impacted with wall
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	# Impacted with enemy
	if area.has_method("damage"):
		area.damage(damage)
	queue_free()
