class_name UserSettings extends Node2D

@onready var done_button : Button = %doneButton
@onready var full_screen_checkbox : CheckBox = %fullScreenCheckbox
@onready var music_volume = %musicVolume
@onready var sfx_volume = %sfxVolume
@onready var language_option = %LanguageOption
@onready var vsync_checkbox: CheckBox = %vsyncCheckbox
@onready var sample_fx: AudioStreamPlayer = %sampleFX

@export var default_volume : float = 0.4

var SETTINGS_FILE_PATH : String = "user://settings.cfg"
var _configFile : ConfigFile

var music_bus_index = AudioServer.get_bus_index("music")
var sfx_bus_index = AudioServer.get_bus_index("sfx")

func _init():
	"""Constructor"""
	_configFile = ConfigFile.new()
	var err = _configFile.load(SETTINGS_FILE_PATH)
	if err != OK: 
		print_debug("Error while loading config file: " + str(err))


func _ready():
	"""Used when first loaded on a scene"""
	if Input.get_connected_joypads().size() > 0:
		done_button.grab_focus()
	var is_fullscreen = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN or DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
	# Set ui defaults
	full_screen_checkbox.set_pressed_no_signal(is_fullscreen)
	full_screen_checkbox.text = "on" if is_fullscreen else "off"
	
	var is_vsync_on = DisplayServer.window_get_vsync_mode() != DisplayServer.VSYNC_DISABLED
	vsync_checkbox.set_pressed_no_signal(is_vsync_on)
	vsync_checkbox.text = "on" if is_vsync_on else "off"

	music_volume.set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(music_bus_index)))
	sfx_volume.set_value_no_signal(db_to_linear(AudioServer.get_bus_volume_db(sfx_bus_index)))
	language_option.select(1 if TranslationServer.get_locale().begins_with("es") else 0)

func load_settings():
	"""Load settings from config file and apply them"""
	var err = _configFile.load(SETTINGS_FILE_PATH)
	if err != OK: 
		print_debug("Error while loading config file: " + str(err))
	# apply settings
	var window_mode = _configFile.get_value("settings", "window_mode", DisplayServer.WINDOW_MODE_WINDOWED)
	if DisplayServer.window_get_mode() != window_mode:
		set_window_mode(window_mode)
	var vsync_mode = _configFile.get_value("settings", "vsync_mode", DisplayServer.VSYNC_DISABLED)
	if DisplayServer.window_get_vsync_mode() != vsync_mode:
		set_vsync_mode(vsync_mode)
	var music_volume_config = _configFile.get_value("settings", "music_volume", default_volume)
	set_volume("music", music_volume_config)
	var sfx_volume_config = _configFile.get_value("settings", "sfx_volume", default_volume)
	set_volume("sfx", sfx_volume_config)
	
	var default_language = "es" if TranslationServer.get_locale().begins_with("es") else "en"
	var language_config = _configFile.get_value("settings", "language", default_language)
	set_language(language_config)

func _process(_delta):
	pass

func hide_settings():
	"""Close the settings screen"""
	visible = false

func set_window_mode(custom_window_mode : DisplayServer.WindowMode):
	DisplayServer.window_set_mode(custom_window_mode)

func set_vsync_mode(vsync_mode : DisplayServer.VSyncMode):
	DisplayServer.window_set_vsync_mode(vsync_mode)

func set_config(key: String, value):
	_configFile.set_value("settings", key, value)
	_configFile.save(SETTINGS_FILE_PATH)

func apply_fullscreen(fullscreen : bool):
	var window_mode = DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
	set_window_mode(window_mode)
	set_config("window_mode", window_mode)
	

func apply_vsync(vsync : bool):
	var vsync_mode = DisplayServer.VSYNC_ENABLED if vsync else DisplayServer.VSYNC_DISABLED
	set_vsync_mode(vsync_mode)
	set_config("vsync", vsync_mode)

func _on_done_button_pressed():
	hide_settings()

func _on_full_screen_checkbox_toggled(button_pressed):
	Fx.click.play()
	apply_fullscreen(button_pressed)
	full_screen_checkbox.text = "on" if button_pressed else "off"

func set_volume(bus_name: String, value: float):
	var volume_db = linear_to_db(value)
	match bus_name:
		"music":
			AudioServer.set_bus_volume_db(music_bus_index, volume_db)
		"sfx":
			AudioServer.set_bus_volume_db(sfx_bus_index, volume_db)
		_:
			return

func apply_volume(bus_name: String, value: float):
	set_volume(bus_name, value)
	set_config(bus_name + "_volume", value)

func _on_music_volume_value_changed(value):
	apply_volume("music", value)

func _on_sfx_volume_value_changed(value):
	apply_volume("sfx", value)
	sample_fx.play()

func set_language(lang: String):
	TranslationServer.set_locale(lang)

func apply_language(lang: String):
	set_language(lang)
	if lang == "en":
		language_option.select(0)
	else:
		language_option.select(1)
	set_config("language", lang)


func _on_language_option_item_selected(index):
	if index == 0:
		print("Setting language to English")
		apply_language("en")
	else:
		print("Setting language to Spanish")
		apply_language("es")


func _on_vsync_toggled(button_pressed):
	Fx.click.play()
	apply_vsync(button_pressed)
	vsync_checkbox.text = "on" if button_pressed else "off"

func set_focus():
	done_button.grab_focus()

func _on_visibility_changed() -> void:
	if visible:
		set_focus()
	elif get_parent() != null and get_parent().has_method("set_focus"):
		get_parent().set_focus()
