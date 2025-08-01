extends Control

@onready var retry_run_button: CustomMenuButton = %retryRunButton
@onready var main_menu_button: CustomMenuButton = %mainMenuButton


func _ready() -> void:
	BackgroundMusic.fade_into("game_over", 0, 1)
	retry_run_button.grab_focus()

func _on_disabled_buttons_timer_timeout() -> void:
	retry_run_button.disabled = false
	main_menu_button.disabled = false


func _on_retry_run_button_pressed() -> void:
	Globals.reset_run()
	SceneManager.change_scene("res://levels/00world1/level1.tscn")

func _on_main_menu_button_pressed() -> void:
	Globals.reset_run()
	SceneManager.change_scene("res://scenes/main_menu.tscn")
