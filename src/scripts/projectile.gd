extends Area2D

@export var speed: float = 200
@export var damage: float

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var dir: Vector2 = Vector2.RIGHT.rotated(global_rotation)
	position += dir * speed * delta


func _on_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("enemy") and _body.type == Globals.challenge.GHOST:
		return
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	# Impacted with enemy
	var enemy: Node2D = area.get_parent()
	if enemy.has_method("damage"):
		if enemy.type == Globals.challenge.GHOST:
			%SFX.play()
		else:
			enemy.damage(global_position, damage)
			queue_free()
