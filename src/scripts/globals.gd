extends Node

var current_world : String
var current_level : String

var level : int = 1
var health : int = 6

enum dir {
	LEFT,
	TOP,
	RIGHT,
	BOTTOM
}

var coming_from: dir = dir.LEFT
