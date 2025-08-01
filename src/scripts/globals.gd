extends Node

signal hero_health_update

const DEFAULT_HEALTH: int = 6
var current_world : String
var current_level : String

var level : int = 1
@onready var current_health: int = DEFAULT_HEALTH:
	set(value):
		current_health = value
		hero_health_update.emit()
@onready var max_health: int = DEFAULT_HEALTH:
	set(value):
		current_health = value
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
	SHOP
}

enum powerup {
	PLUS_LIFE,
	PLUS_MAX_LIFE,
	PLUS_MOVE_SPEED,
	PLUS_DAMAGE,
	PLUS_ATTACK_SPEED
}
var challenge_list: Array[challenge] = []
var powerup_list: Array[powerup] = []
var coming_from: dir = dir.LEFT
var user_settings: Node

func _init() -> void:
	# Load settings config
	user_settings = UserSettings.new()
	user_settings.load_settings()

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
		_:
			return {'texture': null, 'text': ""}

func reset_run():
	current_health = DEFAULT_HEALTH
	max_health = DEFAULT_HEALTH
	challenge_list = []
	powerup_list = []
	level = 1

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_fullscreen"):
		var is_fullscreen = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN or DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
		user_settings.apply_fullscreen(not is_fullscreen)
