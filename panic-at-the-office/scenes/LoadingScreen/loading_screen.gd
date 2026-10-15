
extends CanvasLayer

@onready var root: Control = $root
@onready var background: TextureRect = $root/ColorRect/TextureRect
@onready var title_label: Label = $root/ColorRect/MarginContainer/VBoxContainer/Label
@onready var progress_bar: ProgressBar = $root/ColorRect/MarginContainer/VBoxContainer/ProgressBar
@onready var sprite: AnimatedSprite2D = $root/AnimatedSprite2D

@export var loading_duration: float = 4.0

var progress_tween: Tween



func _ready() -> void:
	sprite.play("default")
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false
	root.modulate.a = 0.0
	progress_bar.value = 0

	await get_tree().process_frame
	var layout = Dialogic.Styles.load_style()
	if layout:
		layout.hide()


func show_loading(_scene_name: String) -> void:
	get_tree().paused = true
	visible = true

	progress_bar.value = 0
	set_status("Loading the Game...")

	if progress_tween and progress_tween.is_running():
		progress_tween.kill()

	root.modulate.a = 0.0

	await get_tree().process_frame

	var fade_tween := create_tween()
	fade_tween.tween_property(root, "modulate:a", 1.0, 0.3)
	await fade_tween.finished

	progress_tween = create_tween()
	progress_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	progress_tween.set_trans(Tween.TRANS_LINEAR)
	progress_tween.set_ease(Tween.EASE_IN_OUT)
	progress_tween.tween_property(
		progress_bar,
		"value",
		100.0,
		loading_duration
	)


func set_progress(value: float) -> void:
	progress_bar.value = clampf(value, 0.0, 1.0) * 100.0


func set_status(status: String) -> void:
	title_label.text = status


func hide_loading() -> void:
	if progress_tween and progress_tween.is_running():
		await progress_tween.finished

	var fade_tween := create_tween()
	fade_tween.tween_property(root, "modulate:a", 0.0, 0.3)
	await fade_tween.finished

	get_tree().paused = false
	visible = false
