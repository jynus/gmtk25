extends Node2D

@onready var back_button: Button = %backButton
@onready var you_won_text: RichTextLabel = %youWonText

func _ready() -> void:
	BackgroundMusic.fade_into("win", 0.5, 11)
	if Input.get_connected_joypads().size() > 0:
		back_button.grab_focus()

func _on_back_button_pressed() -> void:
	SceneManager.change_scene("res://scenes/main_menu.tscn")

func _on_credits_button_pressed() -> void:
	SceneManager.change_scene("res://scenes/credits.tscn")

func _on_you_won_text_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))
