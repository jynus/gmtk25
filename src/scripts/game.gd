extends Node2D

@onready var level_complete_screen: Control = %LevelCompleteScreen
@onready var hero: CharacterBody2D = %Hero

func _ready() -> void:
	spawn_enemy()

func _on_spwan_enemy_timer_timeout() -> void:
	spawn_enemy()

func spawn_enemy():
	var pos: Vector2 = Vector2(randf_range(300, 1500), randf_range(300, 800))
	var enemy_scene = preload("res://scene_objects/enemy.tscn")
	var enemy = enemy_scene.instantiate()
	hero.add_sibling(enemy)
	enemy.global_position = pos
	enemy.hero = hero
