extends Node

var player: Player
var biom: Biom
var difficulty: difficulty_enum
var rows := 25
var cols := 25
var pending_dialogue := ""
var is_story := false
var return_scene_path: String = ""
var whereAmI: String = ""
var isHavingGift := false
var isFirstTime := 0

enum difficulty_enum {
	EASY,
	NORMAL,
	HARD
}

func _ready() -> void:
	call_deferred("_preload_dialogue_resources")

func _preload_dialogue_resources() -> void:
	Dialogic.Styles.preload_style()
	Dialogic.preload_timeline("Prolog")
	Dialogic.preload_timeline("Telephone")
	Dialogic.preload_timeline("IntoBackrooms")

func start_new_maze_run() -> void:
	isFirstTime = 0
	Dialogic.VAR.isSecondTime = false
	Dialogic.VAR.tori_met = false
	Dialogic.VAR.toya_met = false
	Dialogic.VAR.tori_met_previous_cycle = false
	Dialogic.VAR.toya_met_previous_cycle = false

func freeze_group(group_name: String):
	for body in get_tree().get_nodes_in_group(group_name):
		body.process_mode = Node.PROCESS_MODE_DISABLED

func unfreeze_group(group_name: String):
	for body in get_tree().get_nodes_in_group(group_name):
		body.process_mode = Node.PROCESS_MODE_INHERIT

func start_dialogue(timeline: String):
	InteractionManager.freeze_world()
	Dialogic.start(timeline)
	await Dialogic.timeline_ended
	InteractionManager.unfreeze_world()
	
func play_idle_dialogue(timeline: String) -> void:
	Dialogic.Inputs.auto_advance.enabled_forced = true

	Dialogic.Inputs.auto_advance.fixed_delay = 1.5
	Dialogic.Inputs.auto_advance.per_word_delay = 0.1
	Dialogic.Inputs.auto_advance.per_character_delay = 0.0
	
	Dialogic.start(timeline)


func stop_dialogue() -> void:
	if Dialogic.current_timeline != null:
		await Dialogic.end_timeline(true)

	Dialogic.Inputs.auto_advance.enabled_forced = false
	Dialogic.Inputs.auto_advance.enabled_until_user_input = false
	Dialogic.Portraits.leave_all_characters("", 0.0, false)
	Dialogic.Text.hide_textbox()
	InteractionManager.unfreeze_world()
