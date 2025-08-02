extends Area2D

@export var speed: float = 200
@export var damage: float

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x += scale.x * speed * delta


func _on_body_entered(_body: Node2D) -> void:
	# Impacted with wall
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	# Impacted with enemy
	var enemy: Node2D = area.get_parent()
	if enemy.has_method("damage"):
		enemy.damage(global_position, damage)
	queue_free()
