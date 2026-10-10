extends Node

@export var idle_time_limit: float = 10.0
@onready var player = get_tree().get_first_node_in_group("player")

var dir = DirAccess.open("res://timelines/Idle/")
var files = dir.get_files()

var idle_timer: float = 0.0
var idle_dialogue_played: bool = false


func _process(delta: float) -> void:
	if player == null:
		print("Nie ma gracza")
		return

	if Dialogic.current_timeline != null:
		return

	var direction := Input.get_vector(
		"move_left", "move_right",
		"move_up", "move_down"
	)

	if direction != Vector2.ZERO:
		idle_timer = 0.0
		idle_dialogue_played = false
		return

	idle_timer += delta
	if idle_timer >= idle_time_limit and Globals.whereAmI == "Backrooms" and not idle_dialogue_played:
		idle_dialogue_played = true
		Globals.play_idle_dialogue("IdleMC")
