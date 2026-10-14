
extends Control

@onready var button: Button = $Button

var escape_count: int = 0
var max_escapes: int = 7

var is_escaping: bool = false
var escape_tween: Tween

func _ready() -> void:
	button.mouse_entered.connect(_on_button_mouse_entered)
	call_deferred("_place_button_in_center")


func _place_button_in_center() -> void:
	var button_size := button.size
	button.set_anchors_preset(Control.PRESET_TOP_LEFT)
	button.size = button_size
	button.position = (size - button_size) * 0.5

func _on_button_mouse_entered() -> void:
	if escape_count >= max_escapes:
		return

	if is_escaping:
		return

	escape_count += 1
	is_escaping = true

	var button_size := button.size

	var max_x := maxf(0.0, size.x - button_size.x)
	var max_y := maxf(0.0, size.y - button_size.y)

	var new_position := Vector2(
		randf_range(0.0, max_x),
		randf_range(0.0, max_y)
	)

	if escape_tween and escape_tween.is_running():
		escape_tween.kill()

	escape_tween = create_tween()
	escape_tween.set_trans(Tween.TRANS_BACK)
	escape_tween.set_ease(Tween.EASE_OUT)

	escape_tween.tween_property(
		button,
		"position",
		new_position,
		0.35
	)

	escape_tween.finished.connect(_on_escape_finished)

func _on_escape_finished() -> void:
	is_escaping = false
