extends Node

enum Transition {NONE, FADE_TO_BLACK, DISOLVE}
@onready var fade_out_panel: Polygon2D = %FadeOutPanel

func reset_panel():
	fade_out_panel.hide()
	fade_out_panel.texture = null
	fade_out_panel.self_modulate = Color(Color.BLACK, 0.0)

func _do_transition(do_stuff: Callable, transition: Transition, time: float):
	match transition:
		Transition.NONE:
			do_stuff.call()
		Transition.FADE_TO_BLACK:
			fade_out_panel.self_modulate = Color(Color.BLACK, 0.0)
			fade_out_panel.show()
			var tween = create_tween()
			tween.tween_property(fade_out_panel, "self_modulate", Color(Color.BLACK, 1.0), time / 2.0)
			tween.tween_callback(do_stuff)
			tween.tween_property(fade_out_panel, "self_modulate", Color(Color.BLACK, 0.0), time / 2.0)
			tween.tween_callback(reset_panel)
		Transition.DISOLVE:
			var current_image: Image = get_viewport().get_texture().get_image()
			fade_out_panel.texture = ImageTexture.create_from_image(current_image)
			fade_out_panel.self_modulate = Color(Color.WHITE, 1.0)
			fade_out_panel.show()
			var tween = create_tween()
			tween.tween_callback(do_stuff)
			tween.tween_property(fade_out_panel, "self_modulate", Color(Color.WHITE, 0.0), time)
			tween.tween_callback(reset_panel)
		_:
			do_stuff.call()

func change_scene(scene_file: String, transition: Transition = Transition.NONE, time: float = 0.5):
	var do_stuff : Callable = get_tree().change_scene_to_file.bind(scene_file)
	_do_transition(do_stuff, transition, time)

func show_scene(scene: Node, transition: Transition = Transition.NONE, time: float = 0.5):
	var do_stuff : Callable = scene.show.bind()
	_do_transition(do_stuff, transition, time)

func hide_scene(scene: Node, transition: Transition = Transition.NONE, time: float = 0.5):
	var do_stuff : Callable = scene.hide.bind()
	_do_transition(do_stuff, transition, time)

func reload_current_scene(transition: Transition = Transition.NONE, time: float = 0.5):
	var do_stuff : Callable = get_tree().reload_current_scene.bind()
	_do_transition(do_stuff, transition, time)
