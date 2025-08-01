extends Control

@onready var challenge_icon_rect: TextureRect = %ChallengeIconRect
@onready var challenge_text: Label = %ChallengeText

@export var challenge: Globals.challenge:
	set(value):
		challenge = value
		update_info()

func update_info():
	if challenge == Globals.challenge.CRAB:
		%ChallengeIconRect.texture = preload("res://resources/crab_texture.tres")
		%ChallengeText.text = "+1 Crab"
	else:
		%ChallengeIconRect.texture = null
		%ChallengeText.text = ""


func make_active():
	show()
	%YesButton.grab_focus()
	%ButtonDisabledTimer.start(0.5)

func make_inactive():
	hide()
	%YesButton.disabled = true
	
func _on_button_disabled_timer_timeout() -> void:
	%YesButton.disabled = false

func _on_yes_button_pressed() -> void:
	next_level()

func next_level():
	Globals.level += 1
	Globals.challenge_list.append(challenge)
	SceneManager.reload_current_scene()
