extends Node2D

@onready var level_complete_screen: Control = %LevelCompleteScreen

func _ready():
	BackgroundMusic.fade_into("game", 0)

func _on_win_button_pressed() -> void:
	win_level()

func _on_lose_button_pressed() -> void:
	lose_level()

func win_level():
	level_complete_screen.level_complete(true)

func lose_level():
	level_complete_screen.level_complete(false)
