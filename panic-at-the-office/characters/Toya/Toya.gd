extends  CharacterBody2D

@export var speed: float = 100.0
@export var follow_distance: float = 24

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var interactionArea: Area2D = $InteractionArea

var isFollowing := false
var isTalking := false
var player: CharacterBody2D
var met := false


func _ready() -> void: 
	player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	
	if player == null:
		push_warning("Nie znalezniono gracza w grupie player!")
		set_physics_process(false)
		return
		
	nav_agent.path_desired_distance = 8.0
	nav_agent.target_desired_distance = follow_distance
	

func _physics_process(delta: float) -> void:
	if not isFollowing or isTalking:
		velocity = Vector2.ZERO
		move_and_slide()
		return
	
	if global_position.distance_to(player.global_position) <= follow_distance:
		velocity = Vector2.ZERO
	else:
		nav_agent.target_position = player.global_position
		
		if not nav_agent.is_navigation_finished():
			var next_pos = nav_agent.get_next_path_position()
			velocity = global_position.direction_to(next_pos) * speed
		else:
			velocity = Vector2.ZERO
			
	move_and_slide()


func _interact() -> void:
	if isTalking:
		return
		
	isTalking = true
	velocity = Vector2.ZERO
	
	if met == false:
		Dialogic.VAR.toya_invited = false
		await Globals.start_dialogue("ToyaFirstMeeting")
		met = true
		if Dialogic.VAR.toya_invited:
			isFollowing = true
			met = true
			interactionArea.set_deferred("monitoring", false)
		else:
			isFollowing = false
			met = true
	else:
		if met and isFollowing == false:
			await Globals.start_dialogue("ToyaAfterFirstMeeting")
			if Dialogic.VAR.foundBoth == true:
				interactionArea.set_deffered("monitoring", false)
		
	if Dialogic.VAR.foundBoth == true:
		await Globals.start_dialogue("FoundBoth")
		GiftHUD.show_gift()
		
	isTalking = false
