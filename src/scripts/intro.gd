extends Node2D

@onready var typing_sound: AudioStreamPlayer = %TypingSound
@onready var skip_intro_button: Button = %skipIntroButton
@onready var intro_text: RichTextLabel = %introText

var _intro_animation : Tween
var _animation_finished : bool = false

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if _animation_finished:
			change_to_level_select()
		else:
			_intro_animation.stop()
			intro_text.visible_ratio = 1
			finish_animation()

func finish_animation():
	_animation_finished = true
	skip_intro_button.text = "Go to level selection"
	typing_sound.stop()

func _ready() -> void:
	BackgroundMusic.fade_into("intro")
	skip_intro_button.grab_focus()

	intro_text.visible_ratio = 0
	typing_sound.play()
	_intro_animation = create_tween()
	_intro_animation.tween_property(intro_text, "visible_ratio", 1, 20)
	await _intro_animation.finished
	finish_animation()	
	
func _on_skip_intro_button_pressed() -> void:
	change_to_level_select()

func change_to_level_select():
	SceneManager.change_scene("res://scenes/level_select.tscn", SceneManager.Transition.FADE_TO_BLACK)
