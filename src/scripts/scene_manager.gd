extends Node

enum Transition {
	NONE, FADE_TO_BLACK, DISOLVE,
	SLIDE_LEFT, SLIDE_RIGHT, SLIDE_TOP, SLIDE_BOTTOM,
	CURTAIN_TOP, CURTAIN_LEFT
}
@onready var fade_out_panel: Polygon2D = %FadeOutPanel
@onready var fade_out_panel2: Polygon2D = %FadeOutPanel2
var _next_level_image = preload("res://assets/textures/arena_texture_unexplored.webp")

func reset_panel():
	fade_out_panel.hide()
	fade_out_panel.texture = null
	fade_out_panel.self_modulate = Color(Color.BLACK, 0.0)
	fade_out_panel.position = Vector2.ZERO
	fade_out_panel2.hide()
	fade_out_panel2.texture = null
	fade_out_panel2.self_modulate = Color(Color.BLACK, 0.0)
	fade_out_panel2.position = Vector2(1920, 0)

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
			var tween : Tween = create_tween()
			tween.tween_callback(do_stuff)
			tween.tween_property(fade_out_panel, "self_modulate", Color(Color.WHITE, 0.0), time)
			tween.tween_callback(reset_panel)
		Transition.SLIDE_RIGHT, Transition.SLIDE_LEFT, Transition.SLIDE_TOP, Transition.SLIDE_BOTTOM:
			var current_image: Image = get_viewport().get_texture().get_image()
			fade_out_panel.texture = ImageTexture.create_from_image(current_image)
			fade_out_panel.self_modulate = Color(Color.WHITE, 1.0)
			fade_out_panel.show()
			do_stuff.call()
			fade_out_panel2.texture = _next_level_image
			fade_out_panel.self_modulate = Color(Color.WHITE, 1.0)
			fade_out_panel.position = Vector2.ZERO
			fade_out_panel2.self_modulate = Color(Color.WHITE, 1.0)
			var target: Vector2
			match transition:
				Transition.SLIDE_RIGHT:
					fade_out_panel2.position = Vector2(get_viewport().get_visible_rect().size.x, 0)
					target = Vector2(-get_viewport().get_visible_rect().size.x, 0)
				Transition.SLIDE_LEFT:
					fade_out_panel2.position = Vector2(-get_viewport().get_visible_rect().size.x, 0)
					target = Vector2(get_viewport().get_visible_rect().size.x, 0)
				Transition.SLIDE_TOP:
					fade_out_panel2.position = Vector2(0, -get_viewport().get_visible_rect().size.y)
					target = Vector2(0, get_viewport().get_visible_rect().size.y)
				Transition.SLIDE_BOTTOM:
					fade_out_panel2.position = Vector2(0, get_viewport().get_visible_rect().size.y)
					target = Vector2(0, -get_viewport().get_visible_rect().size.y)
			fade_out_panel2.show()
			var tween = create_tween()
			tween.tween_property(fade_out_panel, "position", target, time)
			tween.parallel().tween_property(fade_out_panel2, "position", Vector2.ZERO, time)
			tween.tween_callback(reset_panel)
			tween.tween_callback(unpause)
		Transition.CURTAIN_TOP:
			var max_size_y = get_viewport().get_visible_rect().size.y
			fade_out_panel.position.y = -max_size_y
			fade_out_panel.self_modulate = Color(Color.BLACK, 1)
			fade_out_panel.show()
			var tween = create_tween()
			tween.tween_property(fade_out_panel, "position", Vector2.ZERO, time / 2.0)
			tween.tween_callback(do_stuff)
			tween.tween_callback(reset_panel)
		Transition.CURTAIN_LEFT:
			var max_size_x = get_viewport().get_visible_rect().size.x
			fade_out_panel.position.x = max_size_x
			fade_out_panel.self_modulate = Color(Color.BLACK, 1)
			fade_out_panel.show()
			var tween = create_tween()
			tween.tween_property(fade_out_panel, "position", Vector2.ZERO, time / 2.0)
			tween.tween_callback(do_stuff)
			tween.tween_property(fade_out_panel, "position", Vector2(-max_size_x, 0), time / 2.0)
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

func unpause():
	get_tree().paused = false
