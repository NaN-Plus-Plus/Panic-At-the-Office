extends CharacterBody2D
class_name WireMonster

const DETECTION_LENGTH = 400.0
const LOST_DETECTION_LENGTH = 800.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@export var nav_agent: NavigationAgent2D
@export var player_detection_area: Area2D
@export var push_force: float = 1.0

var speed: float = 100.0
var is_chasing: bool = false
var is_blocked_by_shield: bool = false

func _ready() -> void:
	match Globals.difficulty:
		Globals.difficulty_enum.EASY:
			speed = 100.0
		Globals.difficulty_enum.NORMAL:
			speed = 120.0
		Globals.difficulty_enum.HARD:
			speed = 140.0
	
	animated_sprite.play("idle")

func _physics_process(_delta: float) -> void:
	if is_blocked_by_shield:
		velocity = Vector2.ZERO
		_update_animation()
		return

	if Globals.player == null or not is_instance_valid(Globals.player):
		velocity = Vector2.ZERO
		_update_animation()
		return

	var player_position = Globals.player.global_position
	if _is_in_npc_safe_zone(player_position) or _is_in_npc_safe_zone(global_position):
		is_chasing = false
		velocity = Vector2.ZERO
		_update_animation()
		return
	if global_position.distance_to(player_position) > 400 and !is_chasing:
		_update_animation()
		return
	
	nav_agent.target_position = player_position
	var target_pos = nav_agent.get_next_path_position()
	
	var path_length: float = nav_agent.get_path_length()
	is_chasing = path_length < DETECTION_LENGTH or (path_length < LOST_DETECTION_LENGTH and is_chasing)
	
	if is_chasing:
		velocity = (target_pos - global_position).normalized() * speed
	else:
		velocity = Vector2.ZERO
	
	move_and_slide()
	_update_animation()
	push_rigid_bodies()


func _is_in_npc_safe_zone(position: Vector2) -> bool:
	for npc in get_tree().get_nodes_in_group("npc_safe_zone"):
		if npc is Node2D and npc.has_method("provides_safe_zone") and npc.call("provides_safe_zone"):
			if position.distance_to(npc.global_position) <= npc.call("get_safe_zone_radius"):
				return true
	return false

func _update_animation() -> void:
	if velocity.length() > 1.0:
		animated_sprite.play("walk")
		if abs(velocity.x) > 1.0:
			animated_sprite.flip_h = velocity.x < 0.0
	else:
		animated_sprite.play("idle")


func set_shield_blocked(blocked: bool) -> void:
	is_blocked_by_shield = blocked
	if blocked:
		velocity = Vector2.ZERO
		_update_animation()

func push_rigid_bodies():
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if collider is RigidBody2D:
			var push_dir := -collision.get_normal()
			if collider.linear_velocity.length() < 60.0:
				collider.apply_central_impulse(push_dir * push_force * get_physics_process_delta_time())
