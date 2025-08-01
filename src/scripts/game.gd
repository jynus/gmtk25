extends Node2D

signal state_changed(current_state)

enum level_type {
	NORMAL,
	SHOP
}
@export var type: level_type = level_type.NORMAL
const SHOP_CHANCE: float = 1

@onready var level_complete_screen: Control = %LevelCompleteScreen
@onready var hero: CharacterBody2D = %Hero
@onready var state_transition_player: AnimationPlayer = %StateTransitionPlayer
@onready var left_door: Sprite2D = %LeftDoor
@onready var right_door: Sprite2D = %RightDoor
@onready var top_door: Sprite2D = %TopDoor
@onready var bottom_door: Sprite2D = %BottomDoor
@onready var life_bar_max: TextureRect = %LifeBarMax
@onready var life_bar_current: TextureRect = %LifeBarCurrent

var level_completion_sound = preload("res://assets/sfx/ES_Notification, Video Game, Win, Positive, Happy 01 - Epidemic Sound.ogg")
var bar_sound = preload("res://assets/sfx/ES_Metal, Scrape, Wheel, Barrow - Epidemic Sound.ogg")
var crab_scene = preload("res://scene_objects/enemies/crab.tscn")
var bat_scene = preload("res://scene_objects/enemies/bat.tscn")
var ghost_scene = preload("res://scene_objects/enemies/ghost.tscn")

enum state {
	ENTER,
	CLOSE_BARS,
	COMBAT,
	OPEN_BARS,
	CHOOSE_DOOR,
	CONFIRM_DOOR,
	EXIT,
	GAME_OVER
}

var current_state : state:
	set(value):
		var old_state: state = current_state
		current_state = value
		state_changed.emit(old_state)
 
func _ready() -> void:
	BackgroundMusic.fade_in("game", 1, 0.5)
	update_level()
	Globals.hero_health_update.connect(update_lifebar)
	update_lifebar()
	update_coins()
	current_state = state.ENTER
	randomize_doors()
	if type != level_type.SHOP:
		for challenge in Globals.challenge_list:
			add_challenge(challenge)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("back"):
		%pauseMenu.pause_game()

	if get_tree().get_node_count_in_group("enemy") <= 0 and current_state == state.COMBAT:
		current_state = state.OPEN_BARS
		%SFX.stream = level_completion_sound
		%SFX.play()
		BackgroundMusic.fade_into("win", 0.5)

func randomize_doors():
	for door in [left_door, right_door, top_door, bottom_door]:
		door.challenge = [
			Globals.challenge.CRAB,
			Globals.challenge.BAT,
			Globals.challenge.GHOST
		].pick_random()

	# Shops should never lead to shops
	if type != level_type.SHOP and randf() < SHOP_CHANCE:
		[left_door, right_door, top_door, bottom_door].pick_random().challenge = Globals.challenge.SHOP

func update_level():
	%Level.text = tr("LEVEL") + " %02d" % Globals.level + "/20"

func update_lifebar():
	life_bar_max.size.x = Globals.max_health * 5
	life_bar_current.size.x = Globals.current_health * 5

func update_coins():
	%CoinCount.text = "x" + str(Globals.coins)

func _on_spawn_enemy_timer_timeout() -> void:
	#spawn_enemy()
	pass

func add_challenge(challenge: Globals.challenge):
	match challenge:
		Globals.challenge.CRAB:
			spawn_enemy(crab_scene)
		Globals.challenge.GHOST:
			spawn_enemy(ghost_scene)
		Globals.challenge.BAT:
			for i in range (3):
				spawn_enemy(bat_scene)
		_:
			pass  # shops shouldn't have any danger

func spawn_enemy(enemy_scene: PackedScene):
	var pos: Vector2 = Vector2(randf_range(300, 1500), randf_range(300, 800))
	var enemy = enemy_scene.instantiate()
	hero.add_sibling(enemy)
	enemy.global_position = pos
	enemy.default_position = pos
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
		hero.can_attack = false
		BackgroundMusic.fade_into("level_complete", 0, 1)
		if type == level_type.NORMAL:
			%TileMapLayerObjects.set_cell(Vector2(1,0), 0, Vector2(5,2))
			%TileMapLayerObjects.set_cell(Vector2(18,0), 0, Vector2(5,2))
			%TileMapLayerObjects.set_cell(Vector2(4,0), 0, Vector2(8, 1))
			%TileMapLayerObjects.set_cell(Vector2(15,0), 0, Vector2(8, 1))
			%TileMapLayerObjects.set_cell(Vector2(4,1), 0, Vector2(8, 2))
			%TileMapLayerObjects.set_cell(Vector2(15,1), 0, Vector2(8, 2))

		if Globals.coming_from != Globals.dir.LEFT:
			left_door.get_node("DetectionArea/Collision").set_deferred("disabled", false)
		if Globals.coming_from != Globals.dir.TOP:
			top_door.get_node("DetectionArea/Collision").set_deferred("disabled", false)
		if Globals.coming_from != Globals.dir.RIGHT:
			right_door.get_node("DetectionArea/Collision").set_deferred("disabled", false)
		if Globals.coming_from != Globals.dir.BOTTOM:
			bottom_door.get_node("DetectionArea/Collision").set_deferred("disabled", false)
	elif current_state == state.GAME_OVER:
		BackgroundMusic.fade_out(1)
		SceneManager.change_scene("res://scene_objects/game_over.tscn", SceneManager.Transition.FADE_TO_BLACK, 2)

func open_bars():
	match Globals.coming_from:
		Globals.dir.LEFT:
			left_door.hide()
			%TileMapLayerFloor.set_cell(Vector2(0,5), 0, Vector2(9, 3))
			%TileMapLayerObjects.set_cell(Vector2(0,5), 0, Vector2(5, 6))
		Globals.dir.RIGHT:
			right_door.hide()
			%TileMapLayerFloor.set_cell(Vector2(19,5), 0, Vector2(9, 3))
			%TileMapLayerObjects.set_cell(Vector2(19,5), 0, Vector2(5, 6))
		Globals.dir.TOP:
			top_door.hide()
			%TileMapLayerFloor.set_cell(Vector2(9,0), 0, Vector2(10, 3))
			%TileMapLayerFloor.set_cell(Vector2(10,0), 0, Vector2(11, 3))
			%TileMapLayerObjects.set_cell(Vector2(9,0), 0, Vector2(5, 6))
			%TileMapLayerObjects.set_cell(Vector2(10,0), 0, Vector2(5, 6))
		Globals.dir.BOTTOM:
			bottom_door.hide()
			%TileMapLayerFloor.set_cell(Vector2(9,10), 0, Vector2(10, 3))
			%TileMapLayerFloor.set_cell(Vector2(10,10), 0, Vector2(11, 3))
			%TileMapLayerObjects.set_cell(Vector2(9,10), 0, Vector2(5, 6))
			%TileMapLayerObjects.set_cell(Vector2(10,10), 0, Vector2(5, 6))
	state_transition_player.play_backwards("bars_go_up")

func close_bars():
	state_transition_player.play("bars_go_up")
	
func _on_left_door_detected(_body: Node2D) -> void:
	show_door_dialog(left_door)

func _on_left_door_undetected(_body: Node2D) -> void:
	hide_door_dialog(left_door)
	
func _on_right_door_detected(_body: Node2D) -> void:
	show_door_dialog(right_door)

func _on_right_door_undetected(_body: Node2D) -> void:
	hide_door_dialog(right_door)

func _on_top_door_detected(_body: Node2D) -> void:
	show_door_dialog(top_door)

func _on_top_door_undetected(_body: Node2D) -> void:
	hide_door_dialog(top_door)

func _on_bottom_door_detected(_body: Node2D) -> void:
	show_door_dialog(bottom_door)

func _on_bottom_door_undetected(_body: Node2D) -> void:
	hide_door_dialog(bottom_door)

func show_door_dialog(door: Node2D):
	Globals.coming_from = door.coming_from
	print_debug("Hero detected near door")
	%ConfirmDoorPanel.challenge = door.challenge
	%ConfirmDoorPanel.make_active()

func hide_door_dialog(_door: Node2D):
	%ConfirmDoorPanel.make_inactive()
	
func _on_hero_health_update() -> void:
	update_lifebar()

func _on_hero_died() -> void:
	current_state = state.GAME_OVER

func _on_hero_pickedup_coins() -> void:
	update_coins()
