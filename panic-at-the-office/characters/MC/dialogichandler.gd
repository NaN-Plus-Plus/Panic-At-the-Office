class_name DialogicHandler
extends Node

const WARMUP_TIMELINE := "IdleMC"

const IDLE_DIALOGUES := [
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

static var _preloaded: Dictionary = {}
static var _warmed_up: bool = false

@export var idle_time_limit: float = 15.0
@export var going_time_limit: float = 10.0
@export_range(0.0, 1.0) var going_chance: float = 0.8

var idle_timer: float = 0.0
var going_timer: float = 0.0
var _idle_running := false


static func preload_idles() -> void:
	var tree := Engine.get_main_loop() as SceneTree
	for dialogue in IDLE_DIALOGUES:
		var timeline_name: String = dialogue["timeline"]
		if _preloaded.has(timeline_name):
			continue
		var timeline = Dialogic.preload_timeline(timeline_name)
		if timeline != null:
			_preloaded[timeline_name] = timeline
		await tree.process_frame


static func warm_up() -> void:
	if _warmed_up:
		return
	_warmed_up = true

	var tree := Engine.get_main_loop() as SceneTree
	var master := AudioServer.get_bus_index("Master")
	var was_muted := AudioServer.is_bus_mute(master)
	AudioServer.set_bus_mute(master, true)

	Dialogic.start(_preloaded.get(WARMUP_TIMELINE, WARMUP_TIMELINE))
	for i in 3:
		await tree.process_frame

	hide_popup()
	Dialogic.end_timeline()

	var frames := 0
	while Dialogic.current_timeline != null and frames < 30:
		await tree.process_frame
		frames += 1

	for i in 3:
		hide_popup()
		await tree.process_frame

	AudioServer.set_bus_mute(master, was_muted)


static func hide_popup() -> void:
	var layout = Dialogic.Styles.get_layout_node()
	if is_instance_valid(layout):
		layout.hide()


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

	for dialogue in IDLE_DIALOGUES:
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
	Dialogic.start(_preloaded.get(chosen["timeline"], chosen["timeline"]))

func _exit_tree() -> void:
	if not _idle_running:
		return
	_idle_running = false
	if Dialogic.current_timeline != null:
		Dialogic.end_timeline()
	hide_popup()
