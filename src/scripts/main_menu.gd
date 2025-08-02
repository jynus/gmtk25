extends Node2D

@onready var exit_button : Button = %ExitButton
@onready var play_button: Button = %PlayButton
@onready var how_to_play_button: Button = %HowToPlayButton
@onready var settings_button: Button = %SettingsButton
@onready var credits_button: Button = %CreditsButton
@onready var settings := %settings
@onready var title: Label = %Title

func _init() -> void:
	pass

func _ready() -> void:
	# Disable exit button if we are on the web
	if OS.get_name() == "Web":
		exit_button.hide()
	set_focus()
	if BackgroundMusic.playing and BackgroundMusic.current_song == "menu":
		pass
	elif BackgroundMusic.current_song != "menu":
		BackgroundMusic.fade_into("menu", 1, 7)
	else:
		BackgroundMusic.fade_in("menu", 7, 1)
	title.text = ProjectSettings.get_setting("application/config/name")

func set_focus() -> void:
	play_button.grab_focus()

func start_new_game() -> void:
	"""Start new play session"""
	SceneManager.change_scene("res://levels/00world1/level1.tscn", SceneManager.Transition.FADE_TO_BLACK)

func show_how_to_play_screen() -> void:
	"""Show the instructions and key bindings"""
	SceneManager.change_scene("res://scenes/how_to_play.tscn", SceneManager.Transition.FADE_TO_BLACK)

func show_settings() -> void:
	"""Show the settings screen"""
	SceneManager.show_scene(settings, SceneManager.Transition.FADE_TO_BLACK)
	settings_button.disabled = false

func show_credits() -> void:
	"""Show the credits screen"""
	SceneManager.change_scene("res://scenes/credits.tscn", SceneManager.Transition.FADE_TO_BLACK)

func exit_game() -> void:
	""""Exit to OS"""
	exit_button.disabled = true
	get_tree().quit()

func _on_play_button_pressed() -> void:
	play_button.disabled = true
	start_new_game()

func _on_how_to_play_button_pressed() -> void:
	how_to_play_button.disabled = true
	show_how_to_play_screen()

func _on_settings_button_pressed() -> void:
	"""Show the settings menu"""
	settings_button.disabled = true
	show_settings()

func _on_credits_button_pressed() -> void:
	credits_button.disabled = true
	show_credits()

func _on_exit_button_pressed() -> void:
	exit_button.disabled = true
	exit_game()
