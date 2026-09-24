extends Node2D


@export var VignetteRect: ColorRect


func _ready() -> void:
	Globals.vignette = VignetteRect.material as ShaderMaterial
