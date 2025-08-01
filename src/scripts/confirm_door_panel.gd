extends Control

@onready var challenge_icon_rect: TextureRect = %ChallengeIconRect
@onready var challenge_text: Label = %ChallengeText

@export var challenge: Globals.challenge:
	set(value):
		challenge = value
		update_info()

func update_info():
	var info: Dictionary = Globals.get_challenge_info(challenge)
	challenge_icon_rect.texture = info.texture
	challenge_text.text = info.text

func make_active():
	show()
	%ButtonDisabledTimer.start(0.8)
	%YesButton.hide()

func make_inactive():
	hide()
	%YesButton.disabled = true
	
func _on_button_disabled_timer_timeout() -> void:
	%YesButton.show()
	%YesButton.grab_focus()
	%YesButton.disabled = false

func _on_yes_button_pressed() -> void:
	next_level()

func next_level():
	Globals.level += 1
	Globals.challenge_list.append(challenge)
	SceneManager.reload_current_scene()
