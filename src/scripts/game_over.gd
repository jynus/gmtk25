extends Control

@onready var retry_run_button: CustomMenuButton = %retryRunButton
@onready var main_menu_button: CustomMenuButton = %mainMenuButton


func _ready() -> void:
	BackgroundMusic.fade_in("game_over")
	retry_run_button.grab_focus()

func _on_disabled_buttons_timer_timeout() -> void:
	retry_run_button.disabled = false
	main_menu_button.disabled = false
