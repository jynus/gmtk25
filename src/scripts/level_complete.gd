extends Control

@export var stars_to_win : int = 4

const TWITTER_SHARE_URL = "https://x.com/intent/tweet?text="
@onready var achievement_sound: AudioStreamPlayer = %achievementSound
@onready var lose_sound: AudioStreamPlayer = %loseSound
@onready var nice_sound: AudioStreamPlayer = %niceSound
@onready var bad_sound: AudioStreamPlayer = %badSound
@onready var grade: TextureProgressBar = %grade
@onready var next_level_button: Button = %nextLevelButton
@onready var main_menu_button: Button = %mainMenuButton
@onready var replay_button: Button = %replayButton
@onready var reaction_text: Label = %reactionText

func level_complete(won: bool):
	SceneManager.show_scene(self, SceneManager.Transition.FADE_TO_BLACK, 1)
	await BackgroundMusic.fade_into("level_complete", 0.5, 2)
	enable_next_level_button(won)

func enable_next_level_button(won):
	if won:
		next_level_button.disabled = false
	main_menu_button.disabled = false
	replay_button.disabled = false

func load_next_level():
	var level_select = load("res://scripts/level_select.gd")
	var ls = level_select.new()
	ls.load_next_level(get_tree())

func return_to_main_menu():
	SceneManager.change_scene("res://scenes/level_select.tscn", SceneManager.Transition.FADE_TO_BLACK)

func reload_current_level():
	SceneManager.reload_current_scene(SceneManager.Transition.FADE_TO_BLACK)


func _on_retry_run_button_pressed() -> void:
	pass # Replace with function body.
