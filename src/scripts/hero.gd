extends CharacterBody2D

@export var weapon: PackedScene = preload("res://scene_objects/projectile.tscn")
@onready var sprite_2d: Sprite2D = $Sprite2D
const SPEED = 400.0
@onready var range_attack_pos_right: Marker2D = $RangeAttackPosRight
@onready var range_attack_pos_left: Marker2D = $RangeAttackPosLeft
@onready var attack_timer: Timer = $AttackTimer

var _can_attack: bool = true

func _physics_process(_delta: float) -> void:
	move()

	if Input.is_action_just_pressed("attack"):
		if _can_attack:
			attack()

func move() -> void:
	var direction := Input.get_vector("left", "right", "up", "down")

	if direction.x > 0:
		sprite_2d.flip_h = false
	elif direction.x < 0:
		sprite_2d.flip_h = true
	velocity = direction * SPEED	
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
	

func _on_attack_timer_timeout() -> void:
	_can_attack = true
