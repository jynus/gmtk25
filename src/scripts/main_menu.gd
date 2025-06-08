extends Node2D

@onready var exit_button : Button = %ExitButton
@onready var play_button: Button = %PlayButton
@onready var settings := %settings
@onready var title: Label = %Title

func _init() -> void:
	# Load settings config
	var user_settings = UserSettings.new()
	user_settings.load_settings()

func _ready() -> void:
	# Disable exit button if we are on the web
	if OS.get_name() == "Web":
		exit_button.hide()
	set_focus()
	if BackgroundMusic.current_song != "menu":
		BackgroundMusic.fade_in("menu", 0.0)
	title.text = ProjectSettings.get_setting("application/config/name")

func set_focus() -> void:
	play_button.grab_focus()

func start_new_game() -> void:
	"""Start new play session"""
	SceneManager.change_scene("res://scenes/intro.tscn", SceneManager.Transition.FADE_TO_BLACK)

func show_how_to_play_screen() -> void:
	"""Show the instructions and key bindings"""
	SceneManager.change_scene("res://scenes/how_to_play.tscn", SceneManager.Transition.FADE_TO_BLACK)

func show_settings() -> void:
	"""Show the settings screen"""
	SceneManager.show_scene(settings, SceneManager.Transition.FADE_TO_BLACK)

func show_credits() -> void:
	"""Show the credits screen"""
	SceneManager.change_scene("res://scenes/credits.tscn", SceneManager.Transition.FADE_TO_BLACK)

func exit_game() -> void:
	""""Exit to OS"""
	get_tree().quit()

func _on_play_button_pressed() -> void:
	start_new_game()

func _on_how_to_play_button_pressed() -> void:
	show_how_to_play_screen()

func _on_settings_button_pressed() -> void:
	"""Show the settings menu"""
	show_settings()

func _on_credits_button_pressed() -> void:
	show_credits()

func _on_exit_button_pressed() -> void:
	exit_game()
