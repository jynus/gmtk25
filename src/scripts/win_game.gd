extends Node2D

@onready var typing_sound: AudioStreamPlayer = %TypingSound
@onready var back_button: Button = %backButton
@onready var you_won_text: RichTextLabel = %youWonText

var _tween : Tween

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		_tween.stop()
		you_won_text.visible_ratio = 1
		typing_sound.stop()

func _ready() -> void:
	BackgroundMusic.fade_into("win")
	if Input.get_connected_joypads().size() > 0:
		back_button.grab_focus()

	you_won_text.visible_ratio = 0
	typing_sound.play()
	_tween = create_tween()
	_tween.finished.connect(on_animation_finish)
	_tween.tween_property(you_won_text, "visible_ratio", 1, 20)

func on_animation_finish():
	typing_sound.stop()
	
func _on_back_button_pressed() -> void:
	SceneManager.change_scene("res://scenes/main_menu.tscn", SceneManager.Transition.FADE_TO_BLACK)

func _on_credits_button_pressed() -> void:
	SceneManager.change_scene("res://scenes/credits.tscn", SceneManager.Transition.FADE_TO_BLACK)
