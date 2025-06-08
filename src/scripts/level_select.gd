extends Node2D

@onready var back_button := %backButton
@onready var load_level_button : PackedScene = preload("res://scene_objects/level_button.tscn")
@onready var levels_container := %levelsContainer
@onready var next_world_button := %nextWorldButton
@onready var previous_world_button := %previousWorldButton
@onready var subtitle_world := %subtitle_world


const levels_path : String = "res://levels"
var levels : Dictionary
var LEVELS_FILE_PATH : String = "user://levels.cfg"
var _configFile : ConfigFile

func _init():
	# Load available worlds and levels
	var dir : DirAccess = DirAccess.open(levels_path)
	if not dir:
		printerr("Warning: could not open directory: ", levels_path)
		return
	var dirs = dir.get_directories()
	for world in dirs:
		var world_dir_path : String = levels_path + "/" + world
		var sub_dir = DirAccess.open(world_dir_path)
		var world_files : Array = sub_dir.get_files()
		var world_levels : Array = []
		for file in world_files:
			if file.ends_with(".tscn") or file.ends_with(".tscn.remap"):
				world_levels.append(file.trim_suffix(".remap"))
		if world_levels.size() >= 1:
			world_levels.sort()
			levels[world] = world_levels
	print(levels)

	# Load user progress
	_configFile = ConfigFile.new()
	var err = _configFile.load(LEVELS_FILE_PATH)
	if err != OK:
		print("Error while loading config file: " + str(err))
	var worlds = levels.keys()
	var first_world = null
	var first_level = null
	if worlds.size() >= 1:
		worlds.sort()
		if levels[worlds[0]].size() >= 1:
			first_world = worlds[0]
			var first_world_levels = levels[worlds[0]]
			first_world_levels.sort()
			first_level = first_world_levels[0]
	Globals.current_world = _configFile.get_value("progress", "current_world", first_world)
	Globals.current_level = _configFile.get_value("progress", "current_level", first_level)
	print_debug("Current world: ", Globals.current_world)
	print_debug("Current level: ", Globals.current_level)


func add_level_button(container, text, level):
	"""Adds a working load level button to the scene"""
	var button : CustomLevelButton = load_level_button.instantiate()
	button.text = text
	if level == null:
		button.disabled = true
	else:
		button.disabled = false
		button.level = level
		button.level_select.connect(level_select)
	container.add_child(button)

func path_to_id(level: String):
	"""
	Returns a string with a level id (without a level prefix or
	an extension)
	"""
	return level.trim_prefix("level").trim_suffix(".tscn")

func _ready():
	# enable controller support
	back_button.grab_focus()
	
	if BackgroundMusic.current_song != "menu":
		BackgroundMusic.fade_in("menu", 1)

	# represent world levels
	if levels.keys().find(Globals.current_world) == -1:
		Globals.current_world = levels.keys()[0]
		print_debug(Globals.current_world)
	for level in levels[Globals.current_world]:
		add_level_button(levels_container, path_to_id(level), level)

	# show or hide world buttons
	if levels.size() != 1:
		subtitle_world.text = Globals.current_world.lstrip("0123456789")
	else:
		subtitle_world.hide()
	var world_index = levels.keys().find(Globals.current_world)
	if world_index == -1 or world_index == 0:
		previous_world_button.hide()
	else:
		previous_world_button.show()
	if world_index == -1 or world_index == levels.size() - 1:
		next_world_button.hide()
	else:
		next_world_button.show()

func level_select(level: String):
	"""Return feedback and load the given leven on the current world"""
	Globals.current_level = level.trim_suffix(".remap")
	print("loading: " + Globals.current_level)
	load_current_level()

func load_current_level():
	_configFile.set_value("progress", "current_world", Globals.current_world)
	_configFile.save(LEVELS_FILE_PATH)
	_configFile.set_value("progress", "current_level", Globals.current_level)
	_configFile.save(LEVELS_FILE_PATH)
	var level_path : String = levels_path + "/" + Globals.current_world + "/" + Globals.current_level
	print("loading level " + level_path)
	SceneManager.change_scene(level_path, SceneManager.Transition.FADE_TO_BLACK)
	
func load_next_level(tree):
	# TODO logic to calculate next level
	var world_index = levels.keys().find(Globals.current_world)
	if world_index == -1:
		print("current_world not found")
		# go to level select
		tree.change_scene_to_file("res://scenes/level_select.tscn")
	var level_index = levels[Globals.current_world].find(Globals.current_level)
	if level_index == -1:
		print("current_level not found")
		if len(levels[Globals.current_world]) > 0:
			# if the world has levels, go to the first one
			Globals.current.world = levels[Globals.current_world][0]
			load_current_level()
		else:
			# if the world has no levels, go to the level select screen
			tree.change_scene_to_file("res://scenes/level_select.tscn")
	elif level_index + 1 >= len(levels[Globals.current_world]):
		# last level of current world
		if world_index + 1 >= len(levels.keys()):
			print("You won the last level")
			tree.change_scene_to_file("res://scenes/win_game.tscn")
		else:
			Globals.current_world = levels.keys()[world_index + 1]
			print("Next world: ", Globals.current_world)
			if len(levels[Globals.current_world]) == 0:
				# next world has no levels, go to level select
				tree.change_scene_to_file("res://scenes/level_select.tscn")
			else:
				Globals.current_level = levels[Globals.current_world][0]
				load_current_level()
	else:
		# we jump to the next level
		Globals.current_level = levels[Globals.current_world][level_index + 1]
		load_current_level()

func go_back_to_main_menu():
	"""Return to main menu"""
	SceneManager.change_scene("res://scenes/main_menu.tscn")

func _on_back_button_pressed():
	go_back_to_main_menu()

func show_world(offset: int):
	"""
	Change the current world to the previous (-1) or next one (1),
	as defined by the offset.
	"""
	var world_index = levels.keys().find(Globals.current_world)
	if world_index == -1:
		return
	var new_world_index : int = world_index + offset
	if new_world_index < 0 or new_world_index > levels.size() - 1:
		return
	Globals.current_world = levels.keys()[new_world_index]
	print_debug("Switching to world: ", Globals.current_world)
	_configFile.set_value("progress", "current_world", Globals.current_world)
	_configFile.save(LEVELS_FILE_PATH)

	# remove buttons and then redraw the screen
	for node in levels_container.get_children():
		node.queue_free()
	_ready()

func _on_previous_world_button_pressed():
	Fx.click.play()
	show_world(-1)

func _on_next_world_button_pressed():
	Fx.click.play()
	show_world(1)
