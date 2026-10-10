extends Node2D

@export var butterfly_scene: PackedScene
@export var butterfly_scale: Vector2 = Vector2(6.0, 6.0)
@export var amount: int = 1000
@export var per_frame: int = 10
@export var spawn_area: Rect2 = Rect2(0, 1100, 1920, 300)
@export var rise_speed: Vector2 = Vector2(80.0, 200.0)
@export var sway_amount: Vector2 = Vector2(20.0, 70.0)
@export var sway_speed: Vector2 = Vector2(1.5, 4.0)
@export var despawn_y: float = -60.0

var spawning: bool = false
var butterflies: Array[Node2D] = []
var data: Array[Dictionary] = []

func start_spawning() -> void:
	if spawning:
		return
	spawning = true
	position = Vector2.ZERO

	var spawned := 0
	while spawned < amount:
		for i in per_frame:
			if spawned >= amount:
				break
			spawn_one()
			spawned += 1
		await get_tree().process_frame
	spawning = false

func spawn_one() -> void:
	var butterfly := butterfly_scene.instantiate() as Node2D
	var start := Vector2(
		randf_range(spawn_area.position.x, spawn_area.end.x),
		randf_range(spawn_area.position.y, spawn_area.end.y)
	)

	butterfly.position = start
	butterfly.scale = butterfly_scale
	add_child(butterfly)

	var sprite: AnimatedSprite2D = butterfly as AnimatedSprite2D
	if sprite == null:
		sprite = butterfly.get_node_or_null("AnimatedSprite2D") as AnimatedSprite2D

	if sprite and sprite.sprite_frames:
		sprite.speed_scale = randf_range(0.7, 1.4)
		sprite.play()

	butterflies.append(butterfly)
	data.append({
		"speed": randf_range(rise_speed.x, rise_speed.y),
		"sway": randf_range(sway_amount.x, sway_amount.y),
		"freq": randf_range(sway_speed.x, sway_speed.y),
		"time": randf() * TAU,
		"base_x": start.x
	})

func _process(delta: float) -> void:
	for i in range(butterflies.size() - 1, -1, -1):
		var b := butterflies[i]
		if not is_instance_valid(b):
			butterflies.remove_at(i)
			data.remove_at(i)
			continue

		var d := data[i]
		d["time"] += delta
		b.position.y -= d["speed"] * delta
		b.position.x = d["base_x"] + sin(d["time"] * d["freq"]) * d["sway"]
		b.rotation = cos(d["time"] * d["freq"]) * 0.3

		if b.position.y < despawn_y:
			b.queue_free()
			butterflies.remove_at(i)
			data.remove_at(i)
