extends CharacterBody2D

signal health_update


@export var weapon: PackedScene = preload("res://scene_objects/projectile.tscn")
@export var current_health: int = 6:
	set(value):
		current_health = value
		health_update.emit()
@export var max_health: int = 6:
	set(value):
		current_health = value
		health_update.emit()

@onready var sprite_2d: Sprite2D = $Sprite2D
const SPEED := 400.0
const DAMAGE_FORCE := 30.0
@export var max_speed: float = 400.0
var _acceleration: Vector2 = Vector2.ZERO
var _friction: float = 5
@onready var range_attack_pos_right: Marker2D = $RangeAttackPosRight
@onready var range_attack_pos_left: Marker2D = $RangeAttackPosLeft
@onready var attack_timer: Timer = $AttackTimer

var _can_attack: bool = true
var can_move: bool = true
var is_paused: bool = true

@export var looking_right: bool = true:
	set(value):
		looking_right = value
		sprite_2d.flip_h = not looking_right

func _physics_process(delta: float) -> void:
	if not is_paused:
		if can_move:
			move(delta)
		if Input.is_action_just_pressed("attack"):
			if _can_attack:
				attack()

func move(delta: float) -> void:
	var direction := Input.get_vector("left", "right", "up", "down")
	if direction.x > 0:
		sprite_2d.flip_h = false
	elif direction.x < 0:
		sprite_2d.flip_h = true
	
	if direction == Vector2.ZERO:
		velocity /= _friction
	else:
		_acceleration = direction * 10000 * delta
		velocity += _acceleration
		if velocity.length() > max_speed:
			velocity = velocity.normalized() * max_speed
	
	move_and_slide()

func attack() -> void:
	_can_attack = false
	var my_weapon = weapon.instantiate()
	add_sibling(my_weapon)
	if sprite_2d.flip_h:
		my_weapon.scale.x *= -1
		my_weapon.global_position = range_attack_pos_left.global_position
	else:
		my_weapon.global_position = range_attack_pos_right.global_position
	attack_timer.start()

func get_damaged(points: int, damage_pos: Vector2):
	can_move = false

	current_health -= points
	if current_health <= 0:
		die()
	
	# apply some feedback
	var direction: Vector2 = (global_position - damage_pos).normalized()
	var new_pos = direction * DAMAGE_FORCE + position
	var tween = create_tween()
	tween.tween_property(self, "position", new_pos, 0.15).set_ease(Tween.EASE_OUT)
	modulate = Color.RED
	tween.play()
	tween.finished.connect(resume_moving)

func resume_moving():
	can_move = true
	modulate = Color.WHITE

func die():
	queue_free()

func _on_attack_timer_timeout() -> void:
	_can_attack = true

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		get_damaged(area.damage_on_touch, area.global_position)
