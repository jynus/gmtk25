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

var _subject : String
var _won : bool
var _mark : float = 0


func explain_grade(mark):
	if mark < 1:
		return "You didn't\neven try!"
	elif _mark <= 1:
		return "Sorry!"
	elif _mark <= 2:
		return "Not enough!"
	elif _mark <= 3:
		return "Almost!"
	elif _mark <= 4:
		return "Nice!"
	elif _mark <= 5:
		return "Well done!"
	elif _mark <= 6:
		return "Ok!"
	elif _mark <= 7:
		return "Great!"
	elif _mark <= 8:
		return "Wow!"
	elif _mark <= 9:
		return "Almost perfect!"
	else:
		return "Perfect!"

func show_comment():
	reaction_text.text = explain_grade(_mark)
	reaction_text.self_modulate = Color.TRANSPARENT
	reaction_text.show()
	var tween : Tween = create_tween()
	tween.tween_property(reaction_text, "self_modulate", Color.WHITE, 0.5)
	await tween.finished
	await get_tree().create_timer(2).timeout
	tween = create_tween()
	tween.tween_property(reaction_text, "self_modulate", Color.TRANSPARENT, 0.5)
	await tween.finished
	reaction_text.hide()

func animate_stars():
	var tween : Tween = create_tween()
	grade.value = 0
	tween.tween_property(grade, "value", _mark, 3)
	await tween.finished

func win_animation():
	_won = true
	achievement_sound.play()
	replay_button.text = "Replay level again"
	await animate_stars()
	enable_next_level_button()
	nice_sound.play()
	show_comment()

func lose_animation():
	_won = false
	lose_sound.play()
	next_level_button.hide()
	replay_button.text = "Retry level"
	await animate_stars()
	enable_next_level_button()
	bad_sound.play()
	show_comment()

func level_complete(_original: Texture2D, expected: Texture2D, submitted: Texture2D, mark: int, subject: String):
	BackgroundMusic.fade_into("level_complete", 4)
	#expected_image.texture = expected
	#submitted_image.texture = submitted
	_mark = mark
	_subject = subject

	if mark >= stars_to_win:
		win_animation()
	else:
		lose_animation()
	if Input.get_connected_joypads().size() > 0:
		next_level_button.grab_focus()
	show()

func enable_next_level_button():
	if _won:
		next_level_button.disabled = false
	main_menu_button.disabled = false
	replay_button.disabled = false

func load_next_level():
	Fx.click.play()
	var level_select = load("res://scripts/level_select.gd")
	var ls = level_select.new()
	ls.load_next_level(get_tree())

func return_to_main_menu():
	Fx.click.play()
	get_tree().change_scene_to_file("res://scenes/level_select.tscn")

func reload_current_level():
	Fx.click.play()
	get_tree().reload_current_scene()
