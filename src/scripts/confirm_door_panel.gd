extends Control

signal powerup_selected(powerup: Globals.powerup)

@onready var challenge_icon_rect: TextureRect = %ChallengeIconRect
@onready var challenge_text: Label = %ChallengeText

var _is_challenge: bool = true
var attached_chest: Node

@export var challenge: Globals.challenge:
	set(value):
		challenge = value
		_is_challenge = true
		update_info()

@export var powerup: Globals.powerup:
	set(value):
		powerup = value
		_is_challenge = false
		update_info()

func update_info():
	var info: Dictionary
	if _is_challenge:
		info = Globals.get_challenge_info(challenge)
	else:
		info = Globals.get_powerup_info(powerup)
	challenge_icon_rect.texture = info.texture
	challenge_text.text = info.text
	if _is_challenge:
		%CostContainer.hide()
		%ConfirmText.text = "Confirm door selection?"
		%ButtonDisabledTimer.start(0.8)
	else:
		%CostText.text = "x " + str(info.cost)
		%CostContainer.show()
		if Globals.coins < info.cost:
			%ConfirmText.text = "Not enough coins"
		else:
			%ButtonDisabledTimer.start(0.8)
			%ConfirmText.text = "Confirm powerup purchase?"
		%YesButton.hide()


func make_active():
	%SFX.play()
	update_info()
	show()

func make_inactive():
	hide()
	%YesButton.disabled = true
	
func _on_button_disabled_timer_timeout() -> void:
	%YesButton.show()
	%YesButton.grab_focus()
	%YesButton.disabled = false

func _on_yes_button_pressed() -> void:
	if _is_challenge:
		next_level()
	else:
		apply_powerup()

func next_level():
	Globals.level += 1
			
	if Globals.level > Globals.last_level:
		BackgroundMusic.fade_into("win", 0.5, 11)
		SceneManager.change_scene("res://scenes/win_game.tscn", SceneManager.Transition.FADE_TO_BLACK, 5)
		return
	
	var transition: SceneManager.Transition
	match Globals.coming_from:
		Globals.dir.LEFT:
			transition = SceneManager.Transition.SLIDE_RIGHT
		Globals.dir.RIGHT:
			transition = SceneManager.Transition.SLIDE_LEFT
		Globals.dir.TOP:
			transition = SceneManager.Transition.SLIDE_BOTTOM
		Globals.dir.BOTTOM:
			transition = SceneManager.Transition.SLIDE_TOP
		_:
			transition = SceneManager.Transition.FADE_TO_BLACK
	if challenge == Globals.challenge.SHOP:
		SceneManager.change_scene("res://levels/00world1/shop.tscn", transition, 1)
	else:
		get_tree().paused = true
		Globals.challenge_list.append(challenge)
		SceneManager.change_scene("res://levels/00world1/level1.tscn", transition, 1)

func apply_powerup():
	make_inactive()
	await attached_chest.open_chest()
	powerup_selected.emit(powerup)
