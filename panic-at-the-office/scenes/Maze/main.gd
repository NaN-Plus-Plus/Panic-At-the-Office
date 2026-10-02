extends Node2D

@export var VignetteRect: ColorRect

func _ready() -> void:
	Globals.vignette = VignetteRect.material as ShaderMaterial
	if Globals.pending_dialogue.is_empty():
		return

	var dialogue := Globals.pending_dialogue
	Globals.pending_dialogue = ""
	await LoadingScreen.hide_loading()
	await Globals.start_dialogue(dialogue)
