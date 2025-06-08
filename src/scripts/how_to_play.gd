extends Node2D
@onready var back_button: Button = %backButton

func _ready() -> void:
	set_focus()

func set_focus() -> void:
	back_button.grab_focus()

func _on_back_button_pressed() -> void:
	SceneManager.change_scene("res://scenes/main_menu.tscn", SceneManager.Transition.FADE_TO_BLACK)
