extends ColorRect
class_name Pixel

var location: Vector2i

signal entered(who: Node2D)
signal exited(who: Node2D)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mouse_entered.connect(enter)
	mouse_exited.connect(exit)

func set_properties(pos: Vector2i, min_size: int, default_color: Color):
	custom_minimum_size = Vector2i(min_size, min_size)
	color = default_color
	location = pos

func enter():
	entered.emit(self)

func exit():
	exited.emit(self)
