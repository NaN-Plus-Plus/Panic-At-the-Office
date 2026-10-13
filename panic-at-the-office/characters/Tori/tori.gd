extends  CharacterBody2D

@export var speed: float = 100.0
@export var follow_distance: float = 52.0
@export var formation_side: float = -18.0
@export var safe_zone_radius: float = 160.0

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var interactionArea: Area2D = $InteractionArea

var isFollowing := false
var isTalking := false
var player: CharacterBody2D
var met := false
var _last_player_direction := Vector2.DOWN
var _last_navigation_target := Vector2.INF


func _ready() -> void: 
	add_to_group("npc_safe_zone")
	player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	
	if player == null:
		push_warning("Nie znalezniono gracza w grupie player!")
		set_physics_process(false)
		return
		
	nav_agent.path_desired_distance = 12.0
	nav_agent.target_desired_distance = 12.0


func provides_safe_zone() -> bool:
	return not isFollowing


func get_safe_zone_radius() -> float:
	return safe_zone_radius
	

func _physics_process(delta: float) -> void:
	if not isFollowing or isTalking:
		_stop_following()
		return
	
	var follow_target := _get_follow_target()
	if _last_navigation_target.distance_to(follow_target) > 4.0:
		nav_agent.target_position = follow_target
		_last_navigation_target = follow_target

	if global_position.distance_to(follow_target) <= nav_agent.target_desired_distance:
		velocity = Vector2.ZERO
	else:
		if not nav_agent.is_navigation_finished():
			var next_pos = nav_agent.get_next_path_position()
			velocity = _get_collision_aware_velocity(next_pos, delta)
		else:
			velocity = Vector2.ZERO
			
	move_and_slide()


func _stop_following() -> void:
	velocity = Vector2.ZERO
	_last_navigation_target = Vector2.INF


func _get_follow_target() -> Vector2:
	if player.velocity.length_squared() > 1.0:
		_last_player_direction = player.velocity.normalized()

	var behind_player := -_last_player_direction * follow_distance
	var side_offset := Vector2(-_last_player_direction.y, _last_player_direction.x) * formation_side
	return player.global_position + behind_player + side_offset


func _get_collision_aware_velocity(next_position: Vector2, delta: float) -> Vector2:
	var desired_direction := global_position.direction_to(next_position)
	if desired_direction == Vector2.ZERO:
		return Vector2.ZERO

	var directions := [
		desired_direction,
		desired_direction.rotated(-0.65),
		desired_direction.rotated(0.65),
		desired_direction.rotated(-1.2),
		desired_direction.rotated(1.2),
	]
	var probe_distance := maxf(speed * delta * 1.5, 12.0)
	for direction in directions:
		if not test_move(global_transform, direction * probe_distance):
			return direction * speed

	return Vector2.ZERO


func _interact() -> void:
	if isTalking:
		return
		
	isTalking = true
	velocity = Vector2.ZERO
	
	if met == false:
		Dialogic.VAR.tori_invited = false
		await Globals.start_dialogue("ToriFirstMeeting")
		met = true
		Dialogic.VAR.tori_met = true
		if Dialogic.VAR.tori_invited:
			isFollowing = true
			met = true
			interactionArea.set_deferred("monitoring", false)
		else:
			isFollowing = false
			met = true
	else:
		if met and isFollowing == false:
			await Globals.start_dialogue("ToriAfterFirstMeeting")
			if Dialogic.VAR.foundBoth == true:
				interactionArea.set_deferred("monitoring", false)
		
	if Dialogic.VAR.foundBoth == true:
		await Globals.start_dialogue("FoundBoth")
		GiftHUD.show_gift()
		
	isTalking = false
