extends Node

signal hero_health_update

const DEFAULT_HEALTH: int = 10
const TOP_HEALTH: int = 16
const DEFAULT_SPEED: float = 400
const DEFAULT_ATTACK_SPEED: float = 0.5
const DEFAULT_ATTACK_DAMAGE: int = 1
const DEFAULT_MELEE_ATTACK_DAMAGE: int = 2

var current_world : String
var current_level : String
var max_speed: float = DEFAULT_SPEED
var attack_speed: float = DEFAULT_ATTACK_SPEED
var attack_damage: float = DEFAULT_ATTACK_DAMAGE
var melee_attack_damage: float = DEFAULT_MELEE_ATTACK_DAMAGE

var level : int = 1
var last_level : int = 20
var hero : Hero

@onready var current_health: int = DEFAULT_HEALTH:
	set(value):
		if value > max_health:
			current_health = max_health
		else:
			current_health = value
		hero_health_update.emit()
@onready var max_health: int = DEFAULT_HEALTH:
	set(value):
		var old_health: int = max_health
		if value > TOP_HEALTH:
			max_health = TOP_HEALTH
		else:
			max_health = value
		if max_health < current_health:
			current_health = max_health
		if max_health > old_health:
			current_health += (max_health - old_health)
		hero_health_update.emit()

enum dir {
	LEFT,
	TOP,
	RIGHT,
	BOTTOM
}

enum challenge {
	CRAB,
	BAT,
	GHOST,
	INCREASED_ENEMY_HEALTH,
	SHOP,
	END
}

enum powerup {
	PLUS_LIFE,
	PLUS_MAX_LIFE,
	PLUS_MOVE_SPEED,
	PLUS_ATTACK_DAMAGE,
	PLUS_ATTACK_SPEED
}
var challenge_list: Array[challenge] = []
var powerup_list: Array[powerup] = []
var coming_from: dir = dir.LEFT
var user_settings: Node
var coins: int = 0
var osk_config: String = "auto"


func _ready() -> void:
	# Load settings config
	user_settings = UserSettings.new()
	user_settings.load_settings()
	randomize()

func get_challenge_info(c: challenge) -> Dictionary:
	match c:
		challenge.CRAB:
			return {
				'texture': preload("res://resources/crab_texture.tres"),
				'text': "+1 " + tr("crab")
			}
		challenge.BAT:
			return {
				'texture': preload("res://resources/bat_texture.tres"),
				'text': "+3 " + tr("bats")
			}
		challenge.GHOST:
			return {
				'texture': preload("res://resources/ghost_texture.tres"),
				'text': "+1 " + tr("ghost")
			}
		challenge.SHOP:
			return {
				'texture': preload("res://resources/chest_texture.tres"),
				'text': tr("shop")
			}
		challenge.END:
			return {
				'texture': preload("res://resources/end_texture.tres"),
				'text': tr("the end?")
			}
		_:
			return {'texture': null, 'text': ""}

func get_powerup_info(p: powerup) -> Dictionary:
	match p:
		powerup.PLUS_LIFE:
			return {'texture': preload("res://resources/plus_life_texture.tres"), 'cost': 2, 'text': "+2 hearts"}
		powerup.PLUS_MAX_LIFE:
			return {'texture': preload("res://resources/plus_max_life_texture.tres"), 'cost': 20, 'text': "+1 max life"}
		powerup.PLUS_MOVE_SPEED:
			return {'texture': preload("res://resources/plus_move_speed.tres"), 'cost': 15, 'text': "+1 move speed"}
		powerup.PLUS_ATTACK_DAMAGE:
			return {'texture': preload("res://resources/plus_attack_damage.tres"), 'cost': 20, 'text': "+1 attack damage"}
		powerup.PLUS_ATTACK_SPEED:
			return {'texture': preload("res://resources/plus_attack_speed.tres"), 'cost': 25, 'text': "+1 attack speed"}
		_:
			return {'texture': preload("res://resources/plus_life_texture.tres"), 'cost': 0, 'text': ""}

func reset_run():
	current_health = DEFAULT_HEALTH
	max_health = DEFAULT_HEALTH
	max_speed = DEFAULT_SPEED
	attack_speed = DEFAULT_ATTACK_SPEED
	attack_damage = DEFAULT_ATTACK_DAMAGE
	melee_attack_damage = DEFAULT_MELEE_ATTACK_DAMAGE
	challenge_list = []
	powerup_list = []
	level = 1
	last_level = 21
	coins = 0
	coming_from = dir.LEFT

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"):
		var is_fullscreen = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN or DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
		user_settings.apply_fullscreen(not is_fullscreen)

func apply_powerup(selected_powerup: powerup):
	powerup_list.append(selected_powerup)
	match selected_powerup:
		powerup.PLUS_LIFE:
			current_health += 4
		powerup.PLUS_MAX_LIFE:
			max_health += 2
		powerup.PLUS_MOVE_SPEED:
			max_speed += 200
		powerup.PLUS_ATTACK_DAMAGE:
			attack_damage += 1
			melee_attack_damage += 2
		powerup.PLUS_ATTACK_SPEED:
			attack_speed *= 0.66
			hero.update_speed_attack(attack_speed)
