extends CharacterBody2D
class_name Hero

signal hero_died
signal pickedup_coins
signal enter_powerup_selection(powerup: Globals.powerup)
signal exit_powerup_selection

@onready var weapon_scene: PackedScene = preload("res://scene_objects/projectile.tscn")
@onready var sprite_2d: Sprite2D = $Sprite2D
const DAMAGE_FORCE := 600.0
var _acceleration: Vector2 = Vector2.ZERO
var _friction: float = 5
var _virtual_joystick_direction: = Vector2.ZERO
@export var facing: Vector2 = Vector2.RIGHT:
	set(value):
		facing = value
		if facing.x >= 0 and is_inside_tree():
			sprite_2d.flip_h = false
			%MeleeWeapon.position.x = 7
		if facing.x < 0 and is_inside_tree():
			sprite_2d.flip_h = true
			%MeleeWeapon.position.x = -9
var hurt_vector: Vector2 = Vector2.ZERO
@onready var range_attack_pos: Marker2D = %RangeAttackPos
@onready var attack_timer: Timer = $AttackTimer
var attack_sound = preload("res://assets/sfx/ES_Impact, Attack - Epidemic Sound.ogg")
var melee_attack_sound = preload("res://assets/sfx/ES_Retro, 8 Bit, Character, Sword, Hit - Epidemic Sound.ogg")
var can_attack: bool = false:
	set(value):
		can_attack = value
		%MeleeWeapon.visible = can_attack
var can_melee_attack: bool = true
var can_move: bool = true:
	set(value):
		can_move = value
		%MovingSFX.stream_paused = not can_move
var is_paused: bool = true:
	set(value):
		is_paused = value
		%MovingSFX.stream_paused = is_paused
		%MeleeWeapon.visible = not is_paused


func _ready() -> void:
	Globals.hero = self
	%MovingSFX.play()
	%MovingSFX.stream_paused = true

func _physics_process(delta: float) -> void:
	if not is_paused:
		move(delta)
		if can_attack and Input.is_action_just_pressed("range_attack"):
				range_attack()
		if can_melee_attack and Input.is_action_just_pressed("melee_attack"):
				melee_attack()

func move(delta: float) -> void:
	if hurt_vector != Vector2.ZERO:
		velocity += hurt_vector
		hurt_vector = Vector2.ZERO
	elif can_move:
		normal_move(delta)
	move_and_slide()

func normal_move(delta: float) -> void:
	var direction : Vector2
	if _virtual_joystick_direction != Vector2.ZERO:
		direction = _virtual_joystick_direction
	else:
		direction = Input.get_vector("left", "right", "up", "down")
	
	if direction == Vector2.ZERO:
		velocity /= _friction
		if not %MovingSFX.stream_paused:
			%MovingSFX.stream_paused = true
	else:
		facing = direction
		if %MovingSFX.stream_paused:
			%MovingSFX.stream_paused = false
		_acceleration = direction * 10000 * delta
		velocity += _acceleration
		if velocity.length() > Globals.max_speed:
			velocity = velocity.normalized() * Globals.max_speed

func range_attack() -> void:
	can_attack = false
	%SFX.stream = attack_sound
	%SFX.play()
	var weapon = weapon_scene.instantiate()
	weapon.damage = Globals.attack_damage
	add_sibling(weapon)
	weapon.global_position = range_attack_pos.global_position
	weapon.rotate(facing.angle())
	attack_timer.start()

func melee_attack():
	can_melee_attack = false
	var tween = create_tween()
	%SwordCollision.set_deferred("disabled", false)
	%SFX.stream = melee_attack_sound
	%SFX.play()
	if facing.x >= 0:
		tween.tween_property(%MeleeWeapon, "rotation_degrees", 90, Globals.attack_speed/5)
	else:
		tween.tween_property(%MeleeWeapon, "rotation_degrees", -90, Globals.attack_speed/5)
	tween.tween_callback(finish_melee_attack).set_delay(Globals.attack_speed/2)

func finish_melee_attack():
	can_melee_attack = true
	%MeleeWeapon.rotation_degrees = 0
	%SwordCollision.set_deferred("disabled", true)
	
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

func _on_weapon_range_area_entered(area: Node2D) -> void:
	var body: Node2D
	if area.is_in_group("enemy"):
		body = area
	elif area.get_parent().is_in_group("enemy"):
		body = area.get_parent()
	if body.has_method("damage"):
		if body.type == Globals.challenge.CRAB:
			%SFX.stream = preload("res://assets/sfx/ES_Metal Bar, Thin, Hit With Metal - Epidemic Sound.ogg")
			%SFX.play()
		else:
			body.damage(global_position, Globals.melee_attack_damage)


func _on_virtual_joystick_analogic_change(dir: Vector2) -> void:
	if can_move:
		_virtual_joystick_direction = dir
