extends CanvasLayer

@onready var root: Control = $root
@onready var background: TextureRect = $root/ColorRect/TextureRect
@onready var title_label: Label = $root/ColorRect/MarginContainer/VBoxContainer/Label
@onready var progress_bar: ProgressBar = $root/ColorRect/MarginContainer/VBoxContainer/ProgressBar


func _ready() -> void:
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
	await get_tree().process_frame
	var tween := create_tween()
	root.modulate.a = 0.0
	tween.tween_property(root, "modulate:a", 1.0, 0.3)
	await tween.finished

	set_status("Preparing dialogue...")
	await DialogicHandler.preload_idles()
	await DialogicHandler.warm_up()
	set_status("Loading the Game...")


func set_progress(value: float) -> void:
	progress_bar.value = clampf(value, 0.0, 1.0) * 100.0


func set_status(status: String) -> void:
	title_label.text = status


func hide_loading() -> void:
	await get_tree().create_timer(2.5).timeout

	var frames := 0
	while Dialogic.current_timeline != null and frames < 30:
		await get_tree().process_frame
		frames += 1

	for i in 3:
		DialogicHandler.hide_popup()
		await get_tree().process_frame

	var tween := create_tween()
	tween.tween_property(root, "modulate:a", 0.0, 0.3)
	await tween.finished
	get_tree().paused = false
	visible = false
