extends Node2D
@onready var back_button: Button = %backButton

func _ready() -> void:
	set_focus()

func set_focus() -> void:
	back_button.grab_focus()

func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
