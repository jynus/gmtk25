extends Node

enum Transition {NONE, FADE_TO_BLACK, DISOLVE, SLIDE_LEFT, SLIDE_RIGHT, CURTAIN_TOP, CURTAIN_LEFT}
@onready var fade_out_panel: Polygon2D = %FadeOutPanel

func reset_panel():
	fade_out_panel.hide()
	fade_out_panel.texture = null
	fade_out_panel.self_modulate = Color(Color.BLACK, 0.0)
	fade_out_panel.position = Vector2.ZERO

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
		Transition.SLIDE_LEFT, Transition.SLIDE_RIGHT:
			pass  # TODO
			#var current_image: Image = get_viewport().get_texture().get_image()
			#fade_out_panel.texture = ImageTexture.create_from_image(current_image)
			#fade_out_panel.self_modulate = Color(Color.WHITE, 1.0)
			#fade_out_panel.show()
			#var tween: Tween = create_tween()
			#tween.tween_callback(do_stuff)
			#await get_tree().process_frame
			#fade_out_panel.texture = ImageTexture.create_from_image(current_image)
			#fade_out_panel.self_modulate = Color(Color.WHITE, 1.0)
			#fade_out_panel.show()
			#var end_offset: Vector2
			#var screen_size_x: float = get_viewport().get_visible_rect().size.x
			#if transition == Transition.SLIDE_LEFT:
				#end_offset = Vector2(screen_size_x, 0)
			#else:
				#end_offset = Vector2(-screen_size_x, 0)
			#tween = create_tween()
			#tween.tween_property(fade_out_panel, "position", end_offset, time)
			#tween = create_tween()
			#tween.tween_callback(reset_panel)
		Transition.CURTAIN_TOP:
			var max_size_y = get_viewport().get_visible_rect().size.y
			fade_out_panel.position.y = -max_size_y
			fade_out_panel.self_modulate = Color(Color.BLACK, 1)
			fade_out_panel.show()
			var tween = create_tween()
			tween.tween_property(fade_out_panel, "position", Vector2.ZERO, time / 2.0)
			tween.tween_callback(do_stuff)
			tween.tween_property(fade_out_panel, "position", Vector2(0, -max_size_y), time / 2.0)
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
