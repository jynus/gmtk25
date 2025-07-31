extends Node

signal hero_health_update

var current_world : String
var current_level : String

var level : int = 1
@onready var current_health: int = 6:
	set(value):
		current_health = value
		hero_health_update.emit()
@onready var max_health: int = 6:
	set(value):
		current_health = value
		hero_health_update.emit()

enum dir {
	LEFT,
	TOP,
	RIGHT,
	BOTTOM
}

var coming_from: dir = dir.LEFT
