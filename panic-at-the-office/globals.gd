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
