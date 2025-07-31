extends Node2D

signal state_changed(current_state)

@export var coming_from : dir = dir.LEFT

@onready var level_complete_screen: Control = %LevelCompleteScreen
@onready var hero: CharacterBody2D = %Hero
@onready var state_transition_player: AnimationPlayer = %StateTransitionPlayer
@onready var left_door: Sprite2D = %LeftDoor
@onready var right_door: Sprite2D = %RightDoor
@onready var top_door: Sprite2D = %TopDoor
@onready var bottom_door: Sprite2D = %BottomDoor


enum state {
	ENTER,
	COMBAT,
	CHOOSE_DOOR,
	EXIT
}

enum dir {
	LEFT,
	TOP,
	RIGHT,
	BOTTOM
}
var current_state : state:
	set(value):
		var old_state: state = current_state
		current_state = value
		state_changed.emit(old_state)
 
func _ready() -> void:
	current_state = state.ENTER

func _process(_delta: float) -> void:
	if get_tree().get_node_count_in_group("enemy") <= 0 and current_state == state.COMBAT:
		current_state = state.CHOOSE_DOOR
		
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
		current_state = state.COMBAT


func _on_state_changed(old_state: Variant) -> void:
	print_debug("Old state: " + str(old_state) + " Current state " + str(current_state))
	if current_state in [state.COMBAT, state.CHOOSE_DOOR]:
		hero.can_move = true
	if current_state == state.ENTER:
		match coming_from:
			dir.LEFT:
				state_transition_player.play("enter_from_left")
			dir.RIGHT:
				state_transition_player.play("enter_from_right")
			dir.TOP:
				state_transition_player.play("enter_from_top")
			dir.BOTTOM:
				state_transition_player.play("enter_from_bottom")
	elif current_state == state.CHOOSE_DOOR:
		if coming_from != dir.LEFT:
			left_door.get_node("DetectionArea/Collision").set_deferred("disabled", false)
		if coming_from != dir.TOP:
			top_door.get_node("DetectionArea/Collision").set_deferred("disabled", false)
		if coming_from != dir.RIGHT:
			right_door.get_node("DetectionArea/Collision").set_deferred("disabled", false)
		if coming_from != dir.BOTTOM:
			bottom_door.get_node("DetectionArea/Collision").set_deferred("disabled", false)
	
func _on_detection_area_body_entered(_body: Node2D) -> void:
	print_debug("Hero detected near door")
