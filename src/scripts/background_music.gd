extends Node

const DEFAULT_MUSIC_VOLUME : float = -25

@onready var music_player : AudioStreamPlayer = %musicPlayer
var fadeout_tween : Tween
var fadein_tween : Tween

var playlist : Dictionary = {
	"menu": "res://assets/music/ES_Albatross - Lexica.ogg",
	"pause": "res://assets/music/ES_Mango Fizz - Jobii.ogg",
	"game": "res://assets/music/ES_Nintendo Revolution - Rolla Coasta.ogg",
	"level_complete": "res://assets/music/ES_Fair N Square - William Benckert.ogg",
	"game_over": "res://assets/music/ES_Ctrl Alt Defeat - Deskant.ogg",
	"shop": "res://assets/music/ES_Before Chill - Yomoti.ogg",
	"win": "res://assets/music/ES_Goodbye Goodnight - One Two Feet.ogg",
}
var _current_song : String = "menu"
var playing : bool = false

@export var current_song : String :
	set (value):
		_set_current_song(value)
	get:
		return _current_song

func _set_current_song(value):
	_current_song = value
	music_player.stream = load(playlist[current_song])

func _ready():
	music_player.volume_db = DEFAULT_MUSIC_VOLUME

func play_song(screen: String, offset : float = 0.0):
	if screen not in playlist.keys() or current_song == screen:
		print_debug(screen, " song wasn't found")
		return
	stop()
	current_song = screen
	music_player.play(offset)
	playing = true

func fade_out(duration: float = 2):
	print_debug("fading out music")
	fadeout_tween = create_tween()
	fadeout_tween.finished.connect(on_fade_out_finished)
	fadeout_tween.tween_property(music_player, "volume_db", -80, duration)

func fade_in(screen: String, offset: float = 0.0, duration: float = 2):
	stop()
	current_song = screen
	music_player.volume_db = -80
	print_debug("playing ", screen)
	music_player.play(offset)
	create_tween().tween_property(music_player, "volume_db", DEFAULT_MUSIC_VOLUME, duration)

func fade_into(screen: String, duration : float = 2, offset: float = 0.0):
	print_debug("fading out music into ", screen)
	fadeout_tween = create_tween()
	fadeout_tween.finished.connect(_fade_into2.bind(screen, offset, duration / 2.0))
	fadeout_tween.tween_property(music_player, "volume_db", -80, duration / 2.0)
	return music_player.get_playback_position()
	
func _fade_into2(screen: String, offset: float = 0.0, duration: float = 2):
	if fadeout_tween.finished.is_connected(_fade_into2):
		fadeout_tween.finished.disconnect(_fade_into2)
	fade_in(screen, offset, duration)
	playing = true

func on_fade_out_finished():
	stop()
	if fadeout_tween.finished.is_connected(on_fade_out_finished):
		fadeout_tween.finished.disconnect(on_fade_out_finished)

func stop() -> float:
	var pos : float = music_player.get_playback_position()
	if music_player.playing:
		music_player.stop()
	playing = false
	return pos
