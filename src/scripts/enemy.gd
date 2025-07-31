extends RigidBody2D

const DAMAGE_FORCE : float = 60
@export var speed : float = 30
@export var current_health : float = 20
@export var hero : Node2D
@export var damage_on_touch : int = 1
var _damage_vector : Vector2 = Vector2.ZERO

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if hero and not hero.is_paused:
		var direction: Vector2 = (global_position - hero.global_position).normalized()
		position -= direction * speed * delta

func damage(from: Vector2, points: float = 1):
	current_health -= points
	_damage_vector = (from - global_position).normalized() * DAMAGE_FORCE
	if current_health <= 0:
		queue_free()

func _integrate_forces(state: PhysicsDirectBodyState2D):
	if _damage_vector != Vector2.ZERO:
		state.apply_central_force(_damage_vector)
		_damage_vector = Vector2.ZERO
	
