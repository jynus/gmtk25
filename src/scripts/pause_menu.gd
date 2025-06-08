extends Control

var paused : bool = false
var on_pause_menu : bool = false
@onready var settings = $settings
@onready var return_button = %returnButton
var previous_music_offset : float = 0

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if paused:
			if on_pause_menu:
				unpause_game("game")
			else:
				hide_settings()
		else:
			pause_game()

func _ready():
	visible = false

func _on_return_button_pressed():
	unpause_game("game")

func hide_settings():
	settings.visible = false
	on_pause_menu = true
	set_focus()

func _on_settings_button_pressed():
	show_settings()

func show_settings():
	settings.visible = true
	on_pause_menu = false

func set_focus():
	return_button.grab_focus()

func _on_main_menu_button_pressed():
	unpause_game("menu")
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")

func pause_game():
	previous_music_offset = BackgroundMusic.fade_into("pause")
	set_focus()
	get_tree().paused = true
	paused = true
	visible = true

func unpause_game(screen: String):
	visible = false
	paused = false
	get_tree().paused = false
	previous_music_offset = BackgroundMusic.fade_into(screen, previous_music_offset)

func _on_reset_level_button_pressed():
	previous_music_offset = 0.0
	unpause_game("game")
	get_tree().reload_current_scene()
