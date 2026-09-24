extends CharacterBody2D


@export var speed: float = 200.0
@export var monster_area: Area2D

var monster: WireMonster


func _ready():
	var camera := get_node_or_null("Camera2D") as Camera2D
	if camera and camera.has_method("snap_to_player"):
		camera.snap_to_player()
	
	Globals.player = self
	
	monster_area.body_entered.connect(monster_detected)
	monster_area.body_exited.connect(monster_left)


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


func monster_detected(body: Node2D):
	if body is WireMonster and !monster:
		monster = body


func monster_left(body: Node2D):
	if body == monster:
		monster = null


func apply_vignette():
	if monster:
		Globals.vignette.set_shader_parameter("strength", clampf(1.0 - global_position.distance_to(monster.global_position) / 200, 0.0, 1.0))
		Globals.vignette.set_shader_parameter("radius", clampf(global_position.distance_to(monster.global_position) / 200, 0.0, 1.0))
	else:
		Globals.vignette.set_shader_parameter("strength", 0)
		Globals.vignette.set_shader_parameter("radius", 1)
