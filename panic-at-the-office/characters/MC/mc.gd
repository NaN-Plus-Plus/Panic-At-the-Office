extends CharacterBody2D
class_name Player

@export var speed: float = 200.0
@export var push_force: float = 80.0

@export var monster_area: Area2D
@export var foxy: AnimatedSprite2D
@export var foxy_sound: AudioStreamPlayer
@export var sprite: AnimatedSprite2D

@export var win_scene_path: String = "res://scenes/WinScreen/win_screen.tscn"

var monster: WireMonster
var game_won: bool = false

func _ready():
	var camera := get_node_or_null("Camera2D") as Camera2D
	if camera and camera.has_method("snap_to_player"):
		camera.snap_to_player()
	
	Globals.player = self
	
	monster_area.body_entered.connect(monster_detected)
	monster_area.body_exited.connect(monster_left)
	
	foxy.animation_finished.connect(foxy_crash)

func _process(_delta):
	apply_vignette()

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
	if game_won or not Globals.biom:
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

func monster_detected(body: Node2D):
	if body is WireMonster and !monster:
		monster = body

func monster_left(body: Node2D):
	if body == monster:
		monster = null

func apply_vignette():
	if not Globals.vignette:
		return

	if monster:
		Globals.vignette.set_shader_parameter("strength", clampf(1.0 - global_position.distance_to(monster.global_position) / 200, 0.0, 1.0))
		Globals.vignette.set_shader_parameter("radius", clampf(global_position.distance_to(monster.global_position) / 200, 0.0, 1.0))
		
		if global_position.distance_to(monster.global_position) < 20:
			foxy.visible = true
			foxy.play("Foxy")
			foxy_sound.play(0.26)
			Globals.vignette.set_shader_parameter("strength", 0)
			monster.queue_free()
	else:
		Globals.vignette.set_shader_parameter("strength", 0)
		Globals.vignette.set_shader_parameter("radius", 1)

func foxy_crash():
	get_tree().quit()
