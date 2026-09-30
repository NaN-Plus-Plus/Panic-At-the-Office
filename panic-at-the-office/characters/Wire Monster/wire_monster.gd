extends CharacterBody2D
class_name WireMonster

const DETECTION_LENGTH = 200.0
const LOST_DETECTION_LENGTH = 800.0

@export var nav_agent: NavigationAgent2D
@export var push_force: float = 1.0
@export var sprite: Sprite2D
@export var silhouette: Sprite2D
@export var random_vector_timer: Timer

@onready var foxy_jumpscare_uid: String = "uid://bngoq4xbhsr7s"

var speed: float = 100.0
var is_chasing: bool = false
var movement_delta: float
var random_vector: Vector2 = Vector2.ZERO

func _ready() -> void:
	match Globals.difficulty:
		Globals.difficulty_enum.EASY:
			speed = 100.0
		Globals.difficulty_enum.NORMAL:
			speed = 120.0
		Globals.difficulty_enum.HARD:
			speed = 140.0
	
	sprite.texture_changed.connect(set_silhouette_texture)
	sprite.frame_changed.connect(set_silhouette_texture)
	random_vector_timer.wait_time = randf_range(1.0, 1.5)
	random_vector_timer.timeout.connect(change_random_vector)

func _physics_process(_delta: float) -> void:
	var player_position = Globals.player.global_position
	var distance_to_player = global_position.distance_to(player_position)
	
	if distance_to_player > 400 and !is_chasing:
		return
	
	if distance_to_player <= 20:
		get_tree().change_scene_to_file(foxy_jumpscare_uid)
		return
	
	nav_agent.target_position = player_position + random_vector if distance_to_player > 50 else nav_agent.get_next_path_position()
	var target_pos = nav_agent.get_next_path_position()
	var path_length: float = nav_agent.get_path_length()
	is_chasing = path_length < DETECTION_LENGTH or (path_length < LOST_DETECTION_LENGTH and is_chasing)
	
	if is_chasing:
		velocity = (target_pos - global_position).normalized() * speed
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()
	
	push_rigid_bodies()

func push_rigid_bodies():
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if collider is RigidBody2D:
			var push_dir := -collision.get_normal()
			if collider.linear_velocity.length() < 60.0:
				collider.apply_central_impulse(push_dir * push_force * get_physics_process_delta_time())


func set_silhouette_texture():
	silhouette.texture = sprite.texture


func change_random_vector():
	random_vector = Vector2.RIGHT.rotated(randf_range(0, TAU)) * randf_range(30, 50)
