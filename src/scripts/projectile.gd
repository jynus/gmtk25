extends Area2D

@export var speed: float = 200
@export var damage: float

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var dir: Vector2 = Vector2.RIGHT.rotated(global_rotation)
	position += dir * speed * delta


func _on_area_entered(area: Node2D) -> void:
	var body: Node2D
	if area.get_parent().is_in_group("enemy"):
		body = area.get_parent()
	else:
		body = area
	#it is an enemy
	if body.is_in_group("enemy") and body.has_method("damage"):
		if body.type == Globals.challenge.GHOST:
			%SFX.play()
			return
		body.damage(global_position, damage)
	queue_free()
