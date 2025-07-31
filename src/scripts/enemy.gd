extends Area2D

@export var speed : float = 30
@export var current_health : float = 20
@export var hero : Node2D
@export var damage_on_touch : int = 1

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if hero and not hero.is_paused:
		var direction: Vector2 = (global_position - hero.global_position).normalized()
		position -= direction * speed * delta

func damage(points: float = 1):
	current_health -= points
	if current_health <= 0:
		queue_free()
