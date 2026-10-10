extends CharacterBody2D

@export_group("Speed")
@export var start_speed: float = 50.0
@export var max_speed: float = 150.0
@export var acceleration: float = 10.0   

@export var repath_interval: float = 0.25
@export var chase_on_start: bool = true

@export_group("Meow")
@export var meow_sound: AudioStream
@export var meow_min_time: float = 4.0
@export var meow_max_time: float = 10.0
@export var min_distance: float = 100.0
@export var max_distance: float = 1500.0
@export var quiet_db: float = -40.0
@export var loud_db: float = 0.0

@export_group("Meow Shake")
@export var shake_enabled: bool = true
@export var shake_max_strength: float = 6.0
@export var shake_duration: float = 0.35
@export var shake_max_distance: float = 800.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var agent: NavigationAgent2D = $NavigationAgent2D
@onready var meow_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var area_2d: Area2D = $Area2D

var current_speed: float = 0.0
var triggered: bool = false
var chasing: bool = false
var repath_timer: Timer
var meow_timer: Timer

var _shake_time_left: float = 0.0
var _shake_strength: float = 0.0
var _shake_camera: Camera2D

func _ready() -> void:
	current_speed = start_speed
	animated_sprite_2d.play("walk")
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING

	meow_player.stream = meow_sound

	repath_timer = Timer.new()
	repath_timer.wait_time = repath_interval
	repath_timer.timeout.connect(_update_target)
	add_child(repath_timer)

	meow_timer = Timer.new()
	meow_timer.one_shot = true
	meow_timer.timeout.connect(_on_meow_timer_timeout)
	add_child(meow_timer)
	_schedule_next_meow()

	if not area_2d.body_entered.is_connected(_on_area_2d_body_entered):
		area_2d.body_entered.connect(_on_area_2d_body_entered)

	if chase_on_start:
		start_chasing()

func start_chasing() -> void:
	if chasing:
		return
	chasing = true
	current_speed = start_speed
	await get_tree().physics_frame
	_update_target()
	repath_timer.start()

func stop_chasing() -> void:
	chasing = false
	repath_timer.stop()

func _process(delta: float) -> void:
	_update_meow_volume()
	_update_shake(delta)

func _physics_process(delta: float) -> void:
	if not chasing or triggered or not _player_valid() or agent.is_navigation_finished():
		velocity = Vector2.ZERO
		move_and_slide()
		return

	current_speed = minf(current_speed + acceleration * delta, max_speed)

	var next_pos := agent.get_next_path_position()
	var dir := global_position.direction_to(next_pos)
	velocity = dir * current_speed
	move_and_slide()

	if absf(dir.x) > 0.05:
		animated_sprite_2d.flip_h = dir.x < 0.0

func _player_valid() -> bool:
	return Globals.player != null and is_instance_valid(Globals.player)

func _update_target() -> void:
	if _player_valid():
		agent.target_position = Globals.player.global_position

func _update_meow_volume() -> void:
	if not _player_valid():
		return
	var dist := Globals.player.global_position.distance_to(global_position)
	var t := 1.0 - clampf(inverse_lerp(min_distance, max_distance, dist), 0.0, 1.0)
	meow_player.volume_db = lerpf(quiet_db, loud_db, t)

func _schedule_next_meow() -> void:
	meow_timer.start(randf_range(meow_min_time, meow_max_time))

func _on_meow_timer_timeout() -> void:
	if meow_sound:
		meow_player.pitch_scale = randf_range(0.9, 1.1)
		meow_player.play()
		_start_shake()
	_schedule_next_meow()

func _start_shake() -> void:
	if not shake_enabled or not _player_valid():
		return
	var dist := Globals.player.global_position.distance_to(global_position)
	var t := 1.0 - clampf(inverse_lerp(min_distance, shake_max_distance, dist), 0.0, 1.0)
	if t <= 0.0:
		return
	_shake_camera = get_viewport().get_camera_2d()
	if _shake_camera == null:
		return
	_shake_strength = shake_max_strength * t
	_shake_time_left = shake_duration

func _update_shake(delta: float) -> void:
	if _shake_time_left <= 0.0:
		return
	if _shake_camera == null or not is_instance_valid(_shake_camera):
		_shake_time_left = 0.0
		return

	_shake_time_left -= delta
	if _shake_time_left <= 0.0:
		_shake_camera.offset = Vector2.ZERO
		return

	var fade := _shake_time_left / shake_duration
	var s := _shake_strength * fade
	_shake_camera.offset = Vector2(randf_range(-s, s), randf_range(-s, s))

func _exit_tree() -> void:
	if _shake_camera and is_instance_valid(_shake_camera):
		_shake_camera.offset = Vector2.ZERO

func _on_area_2d_body_entered(body: Node2D) -> void:
	if triggered or not body is Player:
		return
	triggered = true

	var target: String = Globals.return_scene_path
	get_tree().change_scene_to_file.call_deferred(target)
