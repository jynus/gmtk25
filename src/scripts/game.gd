extends Node2D

var pixel = preload("res://scene_objects/pixel.tscn")
@onready var original: TextureRect = %original
@onready var canvas: GridContainer = %canvas
@onready var color_picker: ColorPicker = %ColorPicker
@onready var submit_button: Button = %submitButton
@onready var title: Label = %Title
@onready var draw_sound: AudioStreamPlayer = %DrawSound
@onready var erase_sound: AudioStreamPlayer = %EraseSound
@onready var attention_sound: AudioStreamPlayer = %AttentionSound
@onready var fill_sound: AudioStreamPlayer = %FillSound

@export var subject: String
@export var grid_size : Vector2i = Vector2i(1, 1)
@export var pixel_separation : int = 3
@export var default_grid_color : Color = Color("#fefefe")
@export var original_drawing : Texture2D
@export var expected_result : Texture2D

var _current_color : Color = Color.HOT_PINK
var _current_pixel : Pixel
var _painting : bool = false
var _erasing : bool = false
var _min_size : int = 50
var _grid : Array[Array] = []

# Called when the node enters the scene tree for the first time.
func _ready():
	BackgroundMusic.fade_into("game", 0)
	#if Input.get_connected_joypads().size() > 0:
	#	win_button.grab_focus()
	title.text = tr("Draw: ") + tr(subject)
	canvas.columns = grid_size.x
	canvas.add_theme_constant_override("v_separation", pixel_separation)
	canvas.add_theme_constant_override("h_separation", pixel_separation)
	_min_size = canvas.custom_minimum_size.x / max(grid_size.x, grid_size.y) - pixel_separation
	var line : Array[Pixel]
	for i in range(0, grid_size.y):
		line = []
		for j in range(0, grid_size.x):
			line.append(instantiate_pixel(j, i))
		_grid.append(line)
	color_picker.color = _current_color
	original.texture = original_drawing

func instantiate_pixel(x: int, y:int):
	var button : Pixel = pixel.instantiate()
	button.set_properties(Vector2i(x, y), _min_size, default_grid_color)
	button.name = "Pixel" + str(x) + "-" + str(y)
	canvas.add_child(button)
	button.entered.connect(hover_on)
	button.exited.connect(hover_off)
	return button

func hover_on(button):
	_current_pixel = button
	if _painting and _current_pixel.color != _current_color:
		paint(button)
	elif _erasing and _current_pixel.color != default_grid_color:
		erase(button)

func hover_off(button):
	if _current_pixel == button:
		_current_pixel = null

func paint(button):
	erase_sound.stop()
	draw_sound.play()
	print_debug(button.location)
	button.color = _current_color
	

func erase(button):
	draw_sound.stop()
	erase_sound.play()
	print_debug(button.location)
	button.color = default_grid_color

func _on_color_picker_color_changed(color: Color) -> void:
	_current_color = color

func recursive_fill(p: Pixel, color_to_remove: Color, color_to_set: Color):
	print_debug("attempting to fill: ", p.location)
	if p.color != color_to_remove:
		return
	p.color = _current_color
	for next_step : Vector2i in [Vector2i(1, 0), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(0, -1)]:
		var coords : Vector2i = p.location + next_step
		print_debug("is this pixel ok? ", coords)
		if coords.x < 0 or coords.y < 0 or coords.x >= grid_size.x or coords.y >= grid_size.y:
			continue
		recursive_fill(_grid[coords.y][coords.x], color_to_remove, color_to_set)

func fill_from(p: Pixel):
	print_debug("filling from ", p.location)
	# Do nothing if the color is the same as the current one
	if p.color == _current_color:
		attention_sound.play()
		return
	fill_sound.play()
	recursive_fill(p, p.color, _current_color)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("fill") and _current_pixel != null:
		fill_from(_current_pixel)
		_painting = false
		_erasing = false
	elif Input.is_action_just_pressed("paint"):
		_painting = true
		_erasing = false
		if _current_pixel != null:
			paint(_current_pixel)
	if Input.is_action_just_released("paint"):
		_painting = false
		_erasing = false
	if Input.is_action_just_pressed("erase"):
		_erasing = true
		_painting = false
		if _current_pixel != null:
			erase(_current_pixel)
	if Input.is_action_just_released("erase"):
		_erasing = false
		_painting = false
	if Input.is_action_just_pressed("clone") and _current_pixel != null:
		color_picker.color = _current_pixel.color
		_current_color = _current_pixel.color
		_painting = false
		_erasing = false

func _on_submit_button_pressed() -> void:
	draw_sound.stop()
	erase_sound.stop()
	Fx.click.play()
	for button: Pixel in canvas.get_children():
		if button.color == default_grid_color:
			attention_sound.play()
			print_debug("Are you sure? This button is still in the default color: ", str(button.location))
			%ConfirmationDialog.show()
			return
	level_complete()

func level_complete() -> void:
	var img_submitted = Image.create(grid_size.x, grid_size.y, false, Image.FORMAT_RGB8)
	var img_expected = expected_result.get_image()
	var pixels : Array = canvas.get_children()
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var p : Pixel = pixels.pop_front()
			img_submitted.set_pixel(x, y, p.color)
	var submitted_result : Texture2D = ImageTexture.create_from_image(img_submitted)
	var mark : int = grade_image(img_expected, img_submitted)
	print_debug("mark: ", mark)
	%LevelCompleteScreen.level_complete(original_drawing, expected_result, submitted_result, mark, subject)

func color_difference(color_expected: Color, color_submitted: Color) -> float:
	var difference : float
	var coefficients : Vector3i
	if (color_expected.r8 + color_submitted.r8) > 256:
		coefficients = Vector3i(3, 4, 2)
	else:
		coefficients = Vector3i(2, 4, 3)
	difference = coefficients.x * (color_expected.r8 - color_submitted.r8) ** 2 + \
				 coefficients.y * (color_expected.g8 - color_submitted.g8) ** 2 + \
				 coefficients.z * (color_expected.b8 - color_submitted.b8) ** 2
	return difference

func image_difference(img_expected: Image, img_submitted: Image) -> float:
	var pixel_expected : Color
	var pixel_submitted : Color
	var total_difference : float = 0
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			pixel_expected = img_expected.get_pixel(x, y)
			pixel_submitted = img_submitted.get_pixel(x, y)
			total_difference += color_difference(pixel_expected, pixel_submitted)
	var avg_difference = total_difference / grid_size.x / grid_size.y
	print_debug("avg difference: ", avg_difference)
	return avg_difference

func grade_image(img_expected: Image, img_submitted: Image) -> int:
	var difference: float = image_difference(img_expected, img_submitted)

	if difference >= 110000:
		return 0
	elif difference >= 95000:
		return 1
	elif difference >= 80000:
		return 2
	elif difference >= 50000:
		return 3
	elif difference >= 30000:
		return 5
	elif difference >= 20000:
		return 6
	elif difference >= 15000:
		return 7
	elif difference >= 5000:
		return 8
	elif difference >= 1000:
		return 9
	else:
		return 10
