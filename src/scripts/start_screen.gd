extends Node2D

@onready var play_button: CustomMenuButton = %PlayButton


func _ready() -> void:
	play_button.disconnect("button_down", play_button._on_button_down)
	play_button.grab_focus()

func _on_play_button_button_down() -> void:
	Fx.big_click.play()


func _on_play_button_pressed() -> void:
	SceneManager.change_scene("res://scenes/main_menu.tscn", SceneManager.Transition.FADE_TO_BLACK)
