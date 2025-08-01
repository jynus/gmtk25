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
	INCREASED_ENEMY_HEALTH,
	SHOP
}

var challenge_list: Array[challenge] = []
var coming_from: dir = dir.LEFT

func reset_run():
	current_health = DEFAULT_HEALTH
	max_health = DEFAULT_HEALTH
	level = 1
