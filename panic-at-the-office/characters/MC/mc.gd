extends CharacterBody2D
class_name Player

@export var speed: float = 200.0
@export var push_force: float = 80.0

@export var monster_area: Area2D
@export var sprite: AnimatedSprite2D
@export var silhouette: Sprite2D
@export var glitch_rect: CanvasItem
@export_dir var jumpscare_folder: String

@onready var win_scene_path: String = "res://scenes/WinScreen/win_screen.tscn"
@onready var foxy_jumpscare_uid: String = "uid://d2isvn01qwnhg"
@onready var canvas_layer: CanvasLayer = $CanvasLayer

var game_won: bool = false
var caught: bool = false

func _ready():
	canvas_layer.hide()
	var camera := get_node_or_null("Camera2D") as Camera2D
	if camera and camera.has_method("snap_to_player"):
		camera.snap_to_player()

	Globals.player = self
	monster_area.body_entered.connect(_on_monster_area_body_entered)

	sprite.frame_changed.connect(set_silhouette_texture)
	sprite.animation_changed.connect(set_silhouette_texture)

func _physics_process(_delta):
	var direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	velocity = direction * speed

	move_and_slide()

	push_rigid_bodies()
	update_animation(direction)
	check_win_condition()

func push_rigid_bodies():
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if collider is RigidBody2D:
			var push_dir := -collision.get_normal()
			if collider.linear_velocity.length() < 60.0:
				collider.apply_central_impulse(push_dir * push_force * get_physics_process_delta_time())

func check_win_condition():
	if game_won or caught or not Globals.biom:
		return

	var player_cell = Globals.biom.tile_map_layer.local_to_map(Globals.biom.tile_map_layer.to_local(global_position))

	if player_cell == Globals.biom.exit_cell:
		game_won = true
		get_tree().change_scene_to_file(win_scene_path)

func update_animation(direction: Vector2):
	if direction == Vector2.ZERO:
		sprite.play("idle")
		return

	if abs(direction.x) > abs(direction.y):
		if direction.x > 0:
			sprite.play("walk_r")
		else:
			sprite.play("walk_l")
	else:
		if direction.y > 0:
			sprite.play("walk_f")
		else:
			sprite.play("walk_b")

func _on_monster_area_body_entered(body: Node2D):
	if body is WireMonster:
		scene_change()

func scene_change():
	if caught:
		return
	caught = true
	run_catch_sequence()

func pick_random_scene() -> String:
	var scenes: Array[String] = []
	if jumpscare_folder != "":
		for file_name in DirAccess.get_files_at(jumpscare_folder):
			file_name = file_name.trim_suffix(".remap")
			if file_name.ends_with(".tscn"):
				scenes.append(jumpscare_folder.path_join(file_name))
	if scenes.is_empty():
		return foxy_jumpscare_uid
	return scenes.pick_random()

func run_catch_sequence() -> void:
	var target_scene := pick_random_scene()
	Globals.return_scene_path = get_tree().current_scene.scene_file_path

	if glitch_rect == null or glitch_rect.material == null:
		get_tree().change_scene_to_file(target_scene)
		return

	get_tree().paused = true
	var master := AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(master, true)

	canvas_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	canvas_layer.show()

	var mat := glitch_rect.material as ShaderMaterial
	mat.set_shader_parameter("sort", 0.0)

	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(mat, "shader_parameter/sort", 2.0, 1.2).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	await tween.finished

	AudioServer.set_bus_mute(master, false)
	get_tree().paused = false
	get_tree().change_scene_to_file(target_scene)

func set_silhouette_texture():
	silhouette.texture = sprite.sprite_frames.get_frame_texture(sprite.animation, sprite.frame)
