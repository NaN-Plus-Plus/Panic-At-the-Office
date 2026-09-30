extends CharacterBody2D
class_name WireMonster

const DETECTION_LENGTH = 200.0
const LOST_DETECTION_LENGTH = 800.0

@export var nav_agent: NavigationAgent2D
@export var push_force: float = 1.0
@export var sprite: Sprite2D
@export var silhouette: Sprite2D

var speed: float = 100.0
var is_chasing: bool = false
var movement_delta: float

func _ready() -> void:
	match Globals.difficulty:
		Globals.difficulty_enum.EASY:
			speed = 100.0
		Globals.difficulty_enum.NORMAL:
			speed = 120.0
		Globals.difficulty_enum.HARD:
			speed = 140.0
	
	nav_agent.velocity_computed.connect(_on_velocity_computed)
	sprite.texture_changed.connect(set_silhouette_texture)
	sprite.frame_changed.connect(set_silhouette_texture)

func _physics_process(delta: float) -> void:
	var player_position = Globals.player.global_position
	if global_position.distance_to(player_position) > 400 and !is_chasing:
		return
	
	nav_agent.target_position = player_position
	movement_delta = speed * delta
	var next_path_position: Vector2 = nav_agent.get_next_path_position()
	var current_agent_position: Vector2 = global_position
	var new_velocity: Vector2 = (next_path_position - current_agent_position).normalized() * movement_delta
	
	var path_length: float = nav_agent.get_path_length()
	is_chasing = path_length < DETECTION_LENGTH or (path_length < LOST_DETECTION_LENGTH and is_chasing)
	if !is_chasing:
		return
	
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(new_velocity)
	else:
		_on_velocity_computed(new_velocity)
	
	push_rigid_bodies()

func push_rigid_bodies():
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if collider is RigidBody2D:
			var push_dir := -collision.get_normal()
			if collider.linear_velocity.length() < 60.0:
				collider.apply_central_impulse(push_dir * push_force * get_physics_process_delta_time())


func _on_velocity_computed(safe_velocity: Vector2):
	global_position = global_position.move_toward(global_position + safe_velocity, movement_delta)
	move_and_slide()


func set_silhouette_texture():
	silhouette.texture = sprite.texture
