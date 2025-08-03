extends CharacterBody2D
class_name Hero

signal hero_died
signal pickedup_coins
signal enter_powerup_selection(powerup: Globals.powerup)
signal exit_powerup_selection

@export var weapon: PackedScene = preload("res://scene_objects/projectile.tscn")
@onready var sprite_2d: Sprite2D = $Sprite2D
const DAMAGE_FORCE := 600.0
#@export var max_speed: float = 400.0
var _acceleration: Vector2 = Vector2.ZERO
var _friction: float = 5
var hurt_vector: Vector2 = Vector2.ZERO
@onready var range_attack_pos_right: Marker2D = $RangeAttackPosRight
@onready var range_attack_pos_left: Marker2D = $RangeAttackPosLeft
@onready var attack_timer: Timer = $AttackTimer
var attack_sound = preload("res://assets/sfx/ES_Impact, Attack - Epidemic Sound.ogg")
var can_attack: bool = false
var can_move: bool = true:
	set(value):
		can_move = value
		if not can_move:
			%MovingSFX.stream_paused = true
var is_paused: bool = true:
	set(value):
		is_paused = value
		if is_paused:
			%MovingSFX.stream_paused = true

@export var looking_right: bool = true:
	set(value):
		looking_right = value
		sprite_2d.flip_h = not looking_right


func _ready() -> void:
	Globals.hero = self
	%MovingSFX.play()
	%MovingSFX.stream_paused = true

func _physics_process(delta: float) -> void:
	if not is_paused:
		move(delta)
		if Input.is_action_just_pressed("attack"):
			if can_attack:
				attack()

func move(delta: float) -> void:
	if hurt_vector != Vector2.ZERO:
		velocity += hurt_vector
		hurt_vector = Vector2.ZERO
	elif can_move:
		normal_move(delta)
	move_and_slide()

func normal_move(delta: float) -> void:
	var direction := Input.get_vector("left", "right", "up", "down")
	if direction.x > 0:
		sprite_2d.flip_h = false
	elif direction.x < 0:
		sprite_2d.flip_h = true
	
	if direction == Vector2.ZERO:
		velocity /= _friction
		if not %MovingSFX.stream_paused:
			%MovingSFX.stream_paused = true
	else:
		if %MovingSFX.stream_paused:
			%MovingSFX.stream_paused = false
		_acceleration = direction * 10000 * delta
		velocity += _acceleration
		if velocity.length() > Globals.max_speed:
			velocity = velocity.normalized() * Globals.max_speed

func attack() -> void:
	can_attack = false
	%SFX.stream = attack_sound
	%SFX.play()
	var my_weapon = weapon.instantiate()
	my_weapon.damage = Globals.attack_damage
	add_sibling(my_weapon)
	if sprite_2d.flip_h:
		my_weapon.scale.x *= -1
		my_weapon.global_position = range_attack_pos_left.global_position
	else:
		my_weapon.global_position = range_attack_pos_right.global_position
	attack_timer.start()

func get_damaged(points: int, damage_pos: Vector2):
	can_move = false
	%MovingSFX.stream_paused = true
	Globals.current_health -= points
	if Globals.current_health <= 0:
		die()
	
	# apply some feedback
	modulate = Color.RED
	var direction: Vector2 = (global_position - damage_pos).normalized()
	hurt_vector = direction * DAMAGE_FORCE
	%SFX.play()
	%SFX.finished.connect(resume_moving)

func resume_moving():
	can_move = true
	modulate = Color.WHITE
	%SFX.finished.disconnect(resume_moving)

func die():
	%MovingSFX.stream_paused = true
	is_paused = true
	hero_died.emit()

func _on_attack_timer_timeout() -> void:
	can_attack = true

func _on_hurtbox_area_entered(area: Area2D) -> void:
	var enemy: Node = area.get_parent()
	if enemy.is_in_group("enemy") and can_move:
		get_damaged(enemy.damage_on_touch, enemy.global_position)

func pickup_coin(value: int) -> void:
	Globals.coins += value
	pickedup_coins.emit()

func show_powerup(powerup: Globals.powerup, chest: Node):
	print_debug("show_powerup")
	enter_powerup_selection.emit(powerup, chest)

func hide_powerup():
	print_debug("hide_powerup")
	exit_powerup_selection.emit()

func acquire_powerup(powerup: Globals.powerup):
	%Powerup.texture = Globals.get_powerup_info(powerup).texture
	%AnimationPlayer.play("acquire_powerup")
	
func update_speed_attack(time: float):
	%AttackTimer.wait_time = time
