extends Camera2D

@export var smooth_speed := 3.0
@export var pan_in_speed := 1.0
@export var pan_out_speed := 3.0

@onready var target: CharacterBody2D = $".."

var look_offset := Vector2.ZERO
var target_look_offset := Vector2.ZERO
var camera_position := Vector2.ZERO

var _is_ready_to_follow := false


func _ready() -> void:
	top_level = true
	process_mode = Node.PROCESS_MODE_ALWAYS
	camera_position = target.global_position
	_is_ready_to_follow = true

	snap_to_player()


func _physics_process(delta: float) -> void:
	if not _is_ready_to_follow:
		return

	if not is_instance_valid(target):
		return

	update_look_offset(delta)
	update_camera_position(delta)


func update_look_offset(delta: float) -> void:
	var speed := (
		pan_in_speed
		if target_look_offset != Vector2.ZERO
		else pan_out_speed
	)

	var weight := 1.0 - exp(-speed * delta)

	look_offset = look_offset.lerp(
		target_look_offset,
		weight
	)


func update_camera_position(delta: float) -> void:
	var desired_position := target.global_position + look_offset

	var weight := 1.0 - exp(-smooth_speed * delta)

	camera_position = camera_position.lerp(
		desired_position,
		weight
	)

	global_position = pixel_snap(camera_position)


func pixel_snap(positionn: Vector2) -> Vector2:
	return (positionn * zoom).round() / zoom


func snap_to_player() -> void:
	if not is_instance_valid(target):
		return

	look_offset = target_look_offset
	camera_position = target.global_position + look_offset

	global_position = pixel_snap(camera_position)
