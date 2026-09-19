extends CharacterBody2D

@export var speed: float = 200.0

func _physics_process(_delta):
	var direction := Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
		"move_down"
	)

	velocity = direction * speed

	move_and_slide()

func _ready():
	var camera := get_node_or_null("Camera2D") as Camera2D
	if camera and camera.has_method("snap_to_player"):
		camera.snap_to_player()
