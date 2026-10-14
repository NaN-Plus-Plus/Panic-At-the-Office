extends CharacterBody2D

@export var npc_id: String = "tori"          
@export var dialogue_prefix: String = "Tori"  

@export var push_force: float = 80.0
@export var speed: float = 200.0
@export var catch_up_speed: float = 250.0
@export var acceleration: float = 600.0
@export var follow_distance: float = 52.0
@export var formation_side: float = -18.0
@export var turn_smoothing: float = 2.0     
@export var slow_radius: float = 10.0        
@export var catch_up_distance: float = 120.0
@export var repath_distance: float = 16.0
@export var safe_zone_radius: float = 160.0

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var interaction_area: Area2D = $InteractionArea

var is_following := false
var is_talking := false
var met := false

var _player: CharacterBody2D
var _follow_angle := Vector2.DOWN.angle()
var _last_nav_target := Vector2.INF


func _ready() -> void:
	add_to_group("npc_safe_zone")
	_player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	if _player == null:
		push_warning("Player not found in group 'player'!")
		set_physics_process(false)
		return

	nav_agent.path_desired_distance = 12.0
	nav_agent.target_desired_distance = 12.0


func provides_safe_zone() -> bool:
	return not is_following


func get_safe_zone_radius() -> float:
	return safe_zone_radius


func _physics_process(delta: float) -> void:
	push_rigid_bodies()

	if not is_following or is_talking:
		velocity = velocity.move_toward(Vector2.ZERO, acceleration * delta)
		_last_nav_target = Vector2.INF
		move_and_slide()
		return

	var target := _get_follow_target(delta)
	if _last_nav_target.distance_to(target) > repath_distance:
		nav_agent.target_position = target
		_last_nav_target = target

	var distance := global_position.distance_to(target)
	var desired := Vector2.ZERO

	if distance > nav_agent.target_desired_distance and not nav_agent.is_navigation_finished():
		var dir := global_position.direction_to(nav_agent.get_next_path_position())
		var max_speed := catch_up_speed if distance > catch_up_distance else speed
		var ease_factor := clampf(distance / slow_radius, 0.15, 1.0)
		desired = dir * max_speed * ease_factor

	velocity = velocity.move_toward(desired, acceleration * delta)
	move_and_slide()


func _get_follow_target(delta: float) -> Vector2:
	# Smoothly rotate the "behind" direction instead of snapping it
	if _player.velocity.length_squared() > 1.0:
		var weight := 1.0 - exp(-turn_smoothing * delta)
		_follow_angle = lerp_angle(_follow_angle, _player.velocity.angle(), weight)

	var dir := Vector2.from_angle(_follow_angle)
	var behind := -dir * follow_distance
	var side := dir.orthogonal() * formation_side
	return _player.global_position + behind + side


func _interact() -> void:
	if is_talking:
		return
	is_talking = true
	velocity = Vector2.ZERO

	if not met:
		await _first_meeting()
	elif not is_following:
		await Globals.start_dialogue(dialogue_prefix + "AfterFirstMeeting")
		if Dialogic.VAR.foundBoth:
			interaction_area.set_deferred("monitoring", false)

	if Dialogic.VAR.foundBoth:
		await Globals.start_dialogue("FoundBoth")
		GiftHUD.show_gift()

	is_talking = false


func _first_meeting() -> void:
	Dialogic.VAR.set_variable(npc_id + "_invited", false)
	await Globals.start_dialogue(dialogue_prefix + "FirstMeeting")
	met = true
	Dialogic.VAR.set_variable(npc_id + "_met", true)

	is_following = Dialogic.VAR.get_variable(npc_id + "_invited")
	if is_following:
		interaction_area.set_deferred("monitoring", false)
		
func push_rigid_bodies():
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if collider is RigidBody2D:
			var push_dir := -collision.get_normal()
			if collider.linear_velocity.length() < 60.0:
				collider.apply_central_impulse(push_dir * push_force * get_physics_process_delta_time())
