extends Node3D

@export var subject: String
@export var original_mesh: Mesh
@export var expected_scene: PackedScene
@export var default_camera_zoom: float

@onready var original_marker: Marker3D = %originalMarker
@onready var working_marker: Marker3D = %workingMarker
@onready var original_mesh_instance: MeshInstance3D = %originalMeshInstance
@onready var original_camera: Camera3D = %originalCamera
@onready var working_camera: Camera3D = %workingCamera
@onready var working_sub_viewport: SubViewport = %workingSubViewport
@onready var grid_map: GridMap = %GridMap
@onready var add_block_sound: AudioStreamPlayer = %AddBlockSound
@onready var remove_block_sound: AudioStreamPlayer = %RemoveBlockSound
@onready var attention_sound: AudioStreamPlayer = %AttentionSound
@onready var rotate_sound: AudioStreamPlayer = %RotateSound

var _dragging = false
var _carving = false
var _dragging_source: Vector2i = Vector2i.ZERO
var _carving_source: Vector2i = Vector2i.ZERO
var _grid_min_bounds: Vector3i
var _grid_max_bounds: Vector3i

func generate_grid():
	var size: Vector3 = original_mesh_instance.mesh.get_aabb().size
	_grid_min_bounds.x = int(-size.x / grid_map.cell_size.x / 2)
	_grid_max_bounds.x = int(size.x / grid_map.cell_size.x / 2)
	_grid_min_bounds.y = 0  # we start from heigh 0
	_grid_max_bounds.y = int(size.y / grid_map.cell_size.y)
	_grid_min_bounds.z = int(-size.z / grid_map.cell_size.z / 2)
	_grid_max_bounds.z = int(size.z / grid_map.cell_size.z / 2)
	for i in range(_grid_min_bounds.x, _grid_max_bounds.x + 1):
		for j in range(_grid_min_bounds.y, _grid_max_bounds.y + 1):
			for k in range(_grid_min_bounds.z, _grid_max_bounds.z + 1):
				grid_map.set_cell_item(Vector3i(i, j, k), 0)

func _ready() -> void:
	BackgroundMusic.fade_into("game2", 0)
	original_mesh_instance.mesh = original_mesh
	original_camera.fov = default_camera_zoom
	working_camera.fov = default_camera_zoom
	generate_grid()

func collide():
	var mouse_pos : Vector2i = working_sub_viewport.get_mouse_position()
	var ray_length : float = 1000
	var from: Vector3 = working_camera.project_ray_origin(mouse_pos)
	var to: Vector3 = from + working_camera.project_ray_normal(mouse_pos) * ray_length
	var ray_params := PhysicsRayQueryParameters3D.create(from, to)
	var ray_result: Dictionary = get_world_3d().direct_space_state.intersect_ray(ray_params)
	return ray_result

func remove_block():
	var ray_result: Dictionary= collide()
	print_debug("Clicked: ", ray_result)
	if "position" in ray_result:
		remove_block_sound.play()
		grid_map.set_cell_item(grid_map.local_to_map(grid_map.to_local(ray_result.position)), -1)

func add_block():
	var ray_result: Dictionary= collide()
	print_debug("Clicked: ", ray_result)
	if "position" in ray_result:
		var grid_index: Vector3i = grid_map.local_to_map(grid_map.to_local(ray_result.position))
		grid_index += Vector3i(ray_result.normal)
		if grid_index.x >= _grid_min_bounds.x and \
		   grid_index.x <= _grid_max_bounds.x and \
		   grid_index.y >= _grid_min_bounds.y and \
		   grid_index.y <= _grid_max_bounds.y and \
		   grid_index.z >= _grid_min_bounds.z and \
		   grid_index.z <= _grid_max_bounds.z:
			add_block_sound.play()
			grid_map.set_cell_item(grid_index, 0)
			return true
		attention_sound.play()
	return false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("erase"):
		remove_block()
		_carving = true

	if Input.is_action_just_pressed("paint"):
		if add_block():
			return
		_dragging = true
		_dragging_source = get_viewport().get_mouse_position()
		
	if Input.is_action_just_released("paint"):
		_dragging = false
		_carving = false
	if Input.is_action_just_released("erase"):
		_dragging = false
		_carving = false

	if Input.is_action_just_pressed("zoom_in"):
		zoom_in()
	if Input.is_action_just_pressed("zoom_out"):
		zoom_out()

	if _dragging:
		var mouse_pos = get_viewport().get_mouse_position()
		if abs(_dragging_source.x - mouse_pos.x) > 10:
			rotate_models_up((_dragging_source.x - mouse_pos.x) / 10.0)
			_dragging_source.x = mouse_pos.x
		if abs(_dragging_source.y - mouse_pos.y) > 10:
			rotate_models_left((_dragging_source.y - mouse_pos.y) / 10.0)
			_dragging_source.y = mouse_pos.y
	if _carving:
		var mouse_pos : Vector2i = get_viewport().get_mouse_position()
		if mouse_pos.distance_to(_carving_source) > 10: 
			remove_block()
			_carving_source = mouse_pos

func rotate_models_up(degrees: float):
	rotate_sound.play()
	original_marker.rotate_y(deg_to_rad(degrees))
	working_marker.rotation = original_marker.rotation

func rotate_models_left(degrees: float):
	if original_marker.global_rotation_degrees.x > 85 and degrees > 0:
		attention_sound.play()
		return
	if original_marker.global_rotation_degrees.x < -85 and degrees < 0:
		attention_sound.play()
		return
	rotate_sound.play()
	original_marker.rotate_object_local(Vector3.MODEL_LEFT, deg_to_rad(degrees))
	original_marker.global_rotation_degrees.z = 0
	working_marker.rotation = original_marker.rotation
	
func zoom_in():
	rotate_sound.play()
	original_camera.fov += 3
	if original_camera.fov > 100:
		original_camera.fov = 100
	working_camera.fov = original_camera.fov

func zoom_out():
	rotate_sound.play()
	original_camera.fov -= 3
	if original_camera.fov < 1:
		original_camera.fov = 1
	working_camera.fov = original_camera.fov

func move_down(offset: int = 2):
	rotate_sound.play()
	original_camera.v_offset += offset
	if original_camera.v_offset < -100:
		original_camera.v_offset = -100
	if original_camera.v_offset > 100:
		original_camera.v_offset = 100
	working_camera.v_offset = original_camera.v_offset

func move_up(offset: int = 2):
	move_down(-offset)

func move_left(offset: int = 2):
	rotate_sound.play()
	original_camera.h_offset += offset
	if original_camera.h_offset < -25:
		original_camera.h_offset = -25
	if original_camera.h_offset > 25:
		original_camera.h_offset = 25
	working_camera.h_offset = original_camera.h_offset

func move_right(offset: int = 2):
	move_left(-offset)

func _on_left_button_pressed() -> void:
	move_left()

func _on_right_button_pressed() -> void:
	move_right()

func _on_up_button_pressed() -> void:
	move_up()

func _on_down_button_pressed() -> void:
	move_down()


func _on_submit_button_pressed() -> void:
	add_block_sound.stop()
	rotate_sound.stop()
	remove_block_sound.stop()
	attention_sound.stop()
	Fx.click.play()
	var sculpture : Dictionary = {}
	var reference : Dictionary = {}
	var expected_grid : GridMap = expected_scene.instantiate().get_children()[0] if expected_scene != null else null
	print_debug("Sculpted: ", grid_map.get_used_cells())
	print_debug("Expected: ", expected_grid.get_used_cells())
	for i in range(_grid_min_bounds.x, _grid_max_bounds.x + 1):
		for j in range(_grid_min_bounds.y, _grid_max_bounds.y + 1):
			for k in range(_grid_min_bounds.z, _grid_max_bounds.z + 1):
				sculpture[str(i) + "," + str(j) + "," + str(k)] = grid_map.get_cell_item(Vector3i(i, j, k))
				reference[str(i) + "," + str(j) + "," + str(k)] = expected_grid.get_cell_item(Vector3i(i - 1, j, k - 1))
	var mark: int = grade(reference, sculpture)
	%LevelCompleteScreen.level_complete(original_mesh, expected_scene, sculpture, mark, subject, default_camera_zoom, %originalCamera.v_offset, _grid_min_bounds, _grid_max_bounds)
	%Layout.hide()
	%originalMeshInstance.hide()

func grade(reference: Dictionary, sculpture: Dictionary):
	print_debug("Sculpted: ", sculpture)
	print_debug("Expected: ", reference)
	var mark : int = 0
	var num_voxels : int = 0
	var index : String
	for i in range(_grid_min_bounds.x, _grid_max_bounds.x + 1):
		for j in range(_grid_min_bounds.y, _grid_max_bounds.y + 1):
			for k in range(_grid_min_bounds.z, _grid_max_bounds.z + 1):
				num_voxels += 1
				index = str(i) + "," + str(j) + "," + str(k)
				if (sculpture[index] < 0 and reference[index] < 0) or (sculpture[index] >= 0 and reference[index] >= 0):
					mark += 1
	var percentage_correct : float = (float(mark) * 100.0) / float(num_voxels)
	print_debug("mark: ", mark, ", num_voxels: ", num_voxels, ", percentage_correct: ", percentage_correct)
	if percentage_correct < 30:
		return 0
	elif percentage_correct < 50:
		return 1
	elif percentage_correct < 60:
		return 2
	elif percentage_correct < 70:
		return 3
	elif percentage_correct < 80:
		return 4
	elif percentage_correct < 85:
		return 5
	elif percentage_correct < 90:
		return 6
	elif percentage_correct < 95:
		return 7
	elif percentage_correct < 99:
		return 8
	elif percentage_correct < 100:
		return 9
	else:
		return 10
