extends Node

@export var idle_time_limit: float = 10.0
@export var going_time_limit: float = 15.0
@export_range(0.0, 1.0) var going_chance: float = 0.4

var idle_timer: float = 0.0
var going_timer: float = 0.0
var _idle_running := false

var idle_dialogues = [
	{"timeline": "IdleMC", "required": ["MC"], "type": "Idle"},
	{"timeline": "IdleMC_Tori", "required": ["MC", "Tori"], "type": "Idle"},
	{"timeline": "IdleMC_Tori_Toya", "required": ["MC", "Tori", "Toya"], "type": "Idle"},
	{"timeline": "IdleMC_Toya", "required": ["MC", "Toya"], "type": "Idle"},
	{"timeline": "IdleTori", "required": ["Tori"], "type": "Idle"},
	{"timeline": "IdleTori_Toya", "required": ["Tori", "Toya"], "type": "Idle"},
	{"timeline": "IdleToya", "required": ["Toya"], "type": "Idle"},
	{"timeline": "IdleGoingMC", "required": ["MC"], "type": "Going"},
	{"timeline": "IdleGoingMC_Tori", "required": ["MC", "Tori"], "type": "Going"},
	{"timeline": "IdleGoingMC_Tori_Toya", "required": ["MC", "Tori", "Toya"], "type": "Going"},
	{"timeline": "IdleGoingMC_Toya", "required": ["MC", "Toya"], "type": "Going"},
	{"timeline": "IdleGoingTori", "required": ["Tori"], "type": "Going"},
	{"timeline": "IdleGoingTori_Toya", "required": ["Tori", "Toya"], "type": "Going"},
	{"timeline": "IdleGoingToya", "required": ["Toya"], "type": "Going"},
]


func _ready() -> void:
	Dialogic.timeline_ended.connect(_on_timeline_ended)


func _in_labyrinth() -> bool:
	return is_instance_valid(Globals.player) and is_instance_valid(Globals.biom)


func _process(delta: float) -> void:
	if not _in_labyrinth():
		_reset_timers()
		if _idle_running and Dialogic.current_timeline != null:
			Dialogic.end_timeline()
		return

	if Dialogic.current_timeline != null:
		return

	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if direction != Vector2.ZERO:
		idle_timer = 0.0
		going_timer += delta
		if going_timer >= going_time_limit:
			going_timer = 0.0
			if randf() < going_chance:
				play_random_idle("Going")
		return

	going_timer = 0.0
	idle_timer += delta
	if idle_timer >= idle_time_limit:
		idle_timer = 0.0
		play_random_idle("Idle")


func _reset_timers() -> void:
	idle_timer = 0.0
	going_timer = 0.0


func _on_timeline_ended() -> void:
	_idle_running = false


func get_available_idles(dialog_type: String) -> Array:
	var available: Array = []

	for dialogue in idle_dialogues:
		if dialogue["type"] != dialog_type:
			continue

		var valid := true
		for character in dialogue["required"]:
			if character == "Tori" and not Dialogic.VAR.tori_invited:
				valid = false
				break
			if character == "Toya" and not Dialogic.VAR.toya_invited:
				valid = false
				break

		if valid:
			available.append(dialogue)

	return available


func play_random_idle(dialog_type: String) -> void:
	var available := get_available_idles(dialog_type)
	if available.is_empty():
		return

	var chosen = available.pick_random()

	Dialogic.Inputs.auto_advance.enabled_until_user_input = true
	Dialogic.Inputs.auto_advance.fixed_delay = 1.5
	Dialogic.Inputs.auto_advance.per_word_delay = 0.2
	Dialogic.Inputs.auto_advance.per_character_delay = 0.0

	_idle_running = true
	Dialogic.start(chosen["timeline"])
