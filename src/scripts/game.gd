extends Node2D

signal state_changed(current_state)

@export var coming_from : Globals.dir = Globals.dir.LEFT

@onready var level_complete_screen: Control = %LevelCompleteScreen
@onready var hero: CharacterBody2D = %Hero
@onready var state_transition_player: AnimationPlayer = %StateTransitionPlayer
@onready var left_door: Sprite2D = %LeftDoor
@onready var right_door: Sprite2D = %RightDoor
@onready var top_door: Sprite2D = %TopDoor
@onready var bottom_door: Sprite2D = %BottomDoor
@onready var life_bar_max: TextureRect = %LifeBarMax
@onready var life_bar_current: TextureRect = %LifeBarCurrent
enum state {
	ENTER,
	CLOSE_BARS,
	COMBAT,
	OPEN_BARS,
	CHOOSE_DOOR,
	CONFIRM_DOOR,
	EXIT
}

var current_state : state:
	set(value):
		var old_state: state = current_state
		current_state = value
		state_changed.emit(old_state)
 
func _ready() -> void:
	update_level()
	update_lifebar()
	current_state = state.ENTER

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("back"):
		%pauseMenu.pause_game()

	if get_tree().get_node_count_in_group("enemy") <= 0 and current_state == state.COMBAT:
		current_state = state.OPEN_BARS

func update_level():
	%Level.text = "LEVEL %02d" % Globals.level + "/20"

func update_lifebar():
	life_bar_max.size.x = hero.max_health * 5
	life_bar_current.size.x = hero.current_health * 5

func _on_spawn_enemy_timer_timeout() -> void:
	#spawn_enemy()
	pass

func spawn_enemy():
	var pos: Vector2 = Vector2(randf_range(300, 1500), randf_range(300, 800))
	var enemy_scene = preload("res://scene_objects/enemy.tscn")
	var enemy = enemy_scene.instantiate()
	hero.add_sibling(enemy)
	enemy.global_position = pos
	enemy.hero = hero

func _on_state_transition_player_animation_finished(_anim_name: StringName) -> void:
	if current_state == state.ENTER:
		current_state = state.CLOSE_BARS
	elif current_state == state.CLOSE_BARS:
		current_state = state.COMBAT
	elif current_state == state.OPEN_BARS:
		current_state = state.CHOOSE_DOOR

func _on_state_changed(old_state: Variant) -> void:
	print_debug("Old state: " + str(old_state) + " Current state " + str(current_state))
	if current_state in [state.COMBAT, state.CHOOSE_DOOR, state.OPEN_BARS]:
		hero.is_paused = false
	else:
		hero.is_paused = true
	if current_state == state.ENTER:
		match Globals.coming_from:
			Globals.dir.LEFT:
				state_transition_player.play("enter_from_left")
			Globals.dir.RIGHT:
				state_transition_player.play("enter_from_right")
			Globals.dir.TOP:
				state_transition_player.play("enter_from_top")
			Globals.dir.BOTTOM:
				state_transition_player.play("enter_from_bottom")
	elif current_state == state.OPEN_BARS:
		open_bars()
	elif current_state == state.CLOSE_BARS:
		close_bars()
	elif current_state == state.CHOOSE_DOOR:
		if Globals.coming_from != Globals.dir.LEFT:
			left_door.get_node("DetectionArea/Collision").set_deferred("disabled", false)
		if Globals.coming_from != Globals.dir.TOP:
			top_door.get_node("DetectionArea/Collision").set_deferred("disabled", false)
		if Globals.coming_from != Globals.dir.RIGHT:
			right_door.get_node("DetectionArea/Collision").set_deferred("disabled", false)
		if Globals.coming_from != Globals.dir.BOTTOM:
			bottom_door.get_node("DetectionArea/Collision").set_deferred("disabled", false)

func open_bars():
	state_transition_player.play_backwards("bars_go_up")

func close_bars():
	state_transition_player.play("bars_go_up")
	
func _on_detection_area_body_entered(_body: Node2D) -> void:
	pass

func _on_left_door_detected(_body: Node2D) -> void:
	show_door_dialog(left_door)

func _on_right_door_detected(_body: Node2D) -> void:
	show_door_dialog(right_door)

func _on_top_door_detected(_body: Node2D) -> void:
	show_door_dialog(top_door)

func _on_bottom_door_detected(_body: Node2D) -> void:
	show_door_dialog(bottom_door)

func show_door_dialog(door: Node2D):
	Globals.coming_from = door.coming_from
	print_debug("Hero detected near door")
	%ConfirmDoorPanel.show()
	current_state = state.CONFIRM_DOOR
	%NoButton.grab_focus()

func _on_no_button_pressed() -> void:
	%ConfirmDoorPanel.hide()
	current_state = state.CHOOSE_DOOR

func _on_yes_button_pressed() -> void:
	next_level()

func next_level():
	Globals.level += 1
	SceneManager.reload_current_scene()


func _on_hero_health_update() -> void:
	update_lifebar()
