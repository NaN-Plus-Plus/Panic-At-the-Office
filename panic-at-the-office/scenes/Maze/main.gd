extends Node2D


@export var VignetteRect: ColorRect
@export var y_sort: Node2D


func _ready() -> void:
	Globals.vignette = VignetteRect.material as ShaderMaterial
