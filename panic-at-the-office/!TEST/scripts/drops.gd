extends Node2D

@export var drop_scene: PackedScene
@export var top: Marker2D
@export var bottom: Marker2D
@export var interval: float = 0.3
@export var min_per_tick: int = 2
@export var max_per_tick: int = 5
@export var max_alive: int = 50           
@export var spawn_sound: AudioStream
@export var volume_db: float = 0.0
@export var pitch_variation: float = 0.4
@export var max_sounds_per_tick: int = 1

var spawning: bool = false
var alive: int = 0

func _ready() -> void:
	start_spawning()

func start_spawning() -> void:
	if spawning:
		return
	spawning = true
	while spawning:
		var count := randi_range(min_per_tick, max_per_tick)
		for i in count:
			if alive >= max_alive:
				break
			spawn_one(i < max_sounds_per_tick)
			await get_tree().create_timer(randf() * interval / count).timeout
		await get_tree().create_timer(interval).timeout

func stop_spawning() -> void:
	spawning = false

func spawn_one(with_sound: bool = true) -> void:
	var area := Rect2(top.global_position, bottom.global_position - top.global_position).abs()
	var pos := Vector2(
		randf_range(area.position.x, area.end.x),
		randf_range(area.position.y, area.end.y)
	)

	var drop := drop_scene.instantiate() as Node2D
	add_child(drop)
	drop.global_position = pos
	alive += 1
	drop.tree_exited.connect(func(): alive -= 1)

	if with_sound:
		play_sound(pos)

	var sprite := drop as AnimatedSprite2D
	if sprite == null:
		sprite = drop.get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D

	if sprite and sprite.sprite_frames:
		sprite.play()
		sprite.animation_finished.connect(drop.queue_free)
	else:
		get_tree().create_timer(1.0).timeout.connect(drop.queue_free)

func play_sound(pos: Vector2) -> void:
	if spawn_sound == null:
		return
	var player := AudioStreamPlayer2D.new()
	player.stream = spawn_sound
	player.volume_db = volume_db
	player.pitch_scale = 1.0 + randf_range(-pitch_variation, pitch_variation)
	add_child(player)
	player.global_position = pos
	player.finished.connect(player.queue_free)
	player.play()
