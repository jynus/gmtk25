extends CharacterBody2D

signal update_health

const DAMAGE_FORCE : float = 1000
@export var speed : float = 3
@export var max_health : float = 2:
	set(value):
		max_health = value
		update_health.emit()
@onready var current_health : float = 2:
	set(value):
		current_health = value
		update_health.emit()
@export var hero : Node2D
@export var max_speed: float = 200.0
@export var damage_on_touch : int = 1
@export var texture: Texture2D

var hurt_vector : Vector2 = Vector2.ZERO
@onready var max_life_bar: ColorRect = %MaxLifeBar
@onready var current_life_bar: ColorRect = %CurrentLifeBar
@onready var navigation_agent: NavigationAgent2D = %NavigationAgent
var death_sound = preload("res://assets/sfx/ES_Retro, 8 Bit, Explosion, Damage - Epidemic Sound.ogg")
var hit_sound = preload("res://assets/sfx/ES_Retro, 8 Bit, Character, Sword, Hit - Epidemic Sound.ogg")

func _ready() -> void:
	update_texture()
	current_health = max_health
	update_life_bar()
	hero_setup.call_deferred()

func hero_setup():
	await get_tree().physics_frame
	if hero:
		navigation_agent.target_position = hero.global_position
	
func _physics_process(_delta: float) -> void:
	if hurt_vector != Vector2.ZERO:
		velocity += hurt_vector
		hurt_vector /= 10
		if hurt_vector.length() < 1:
			hurt_vector = Vector2.ZERO
	elif hero and not hero.is_paused and not navigation_agent.is_navigation_finished():
		var current_agent_position: Vector2 = global_position
		var next_path_position: Vector2 = navigation_agent.get_next_path_position()
		velocity = current_agent_position.direction_to(next_path_position) * max_speed
		if velocity.length() > max_speed:
			velocity = velocity.normalized() * max_speed
	else:
		velocity = Vector2.ZERO
	move_and_slide()
	hero_setup.call_deferred()

func damage(from: Vector2, points: float = 1):
	current_health -= points
	modulate = Color.RED
	$SFX.stream = hit_sound
	%SFX.play()
	%SFX.finished.connect(damage_end)
	hurt_vector = (global_position - from).normalized() * DAMAGE_FORCE
	if current_health <= 0:
		die()

func die():
	%HitboxCollision.set_deferred("disabled", true)
	%HurtboxCollision.set_deferred("disabled", true)
	var tween = create_tween()
	tween.tween_property(self, "rotation_degrees", 90, 0.5)
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 0.5)
	tween.play()
	tween.finished.connect(die_end)
	$SFX.stream = death_sound
	$SFX.play()
	hero = null
	
func damage_end():
	modulate = Color.WHITE
	%SFX.finished.disconnect(damage_end)

func die_end():
	queue_free()

func _on_update_health() -> void:
	update_life_bar()

func update_life_bar():
	if current_life_bar:
		current_life_bar.size.x = max_life_bar.size.x * (current_health / max_health)

func update_texture():
	%Sprite2D.texture = texture
