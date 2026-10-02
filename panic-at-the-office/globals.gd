extends Node

var player: Player
var vignette: ShaderMaterial
var biom: Biom
var difficulty: difficulty_enum
var rows := 25
var cols := 25
var pending_dialogue := ""
var is_story := false

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
