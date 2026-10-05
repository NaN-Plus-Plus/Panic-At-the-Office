extends Area2D

const OVERLAY_SCENE = preload("uid://2n4bpfkmjh1s")
const FADE_TIME := 0.3

var overlay: CanvasLayer
var fade_targets: Array[CanvasItem] = []
var tween: Tween

func _ready() -> void:
	overlay = OVERLAY_SCENE.instantiate() as CanvasLayer

	for child in overlay.get_children():
		if child is CanvasItem:
			child.modulate.a = 0.0
			fade_targets.append(child)

	overlay.visible = false
	get_tree().current_scene.add_child.call_deferred(overlay)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_fade(1.0)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		_fade(0.0)

func _fade(target_alpha: float) -> void:

	if target_alpha > 0.0:
		overlay.visible = true

	tween = create_tween()
	tween.set_parallel(true) 

	for target in fade_targets:
		tween.tween_property(target, "modulate:a", target_alpha, FADE_TIME)

	if target_alpha == 0.0:
		tween.chain().tween_callback(_hide_overlay)

func _hide_overlay() -> void:
	overlay.visible = false
