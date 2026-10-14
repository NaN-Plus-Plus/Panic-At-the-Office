
extends Label

@export var fade_duration: float = 1.0
@export var visible_duration: float = 2.5

var tween: Tween

func _ready() -> void:
	show_message("- ??? -")

func show_message(message: String) -> void:
	text = message

	if tween and tween.is_running():
		tween.kill()

	modulate.a = 0.0
	show()

	tween = create_tween()

	tween.tween_interval(1.0)
	tween.tween_property(self, "modulate:a", 1.0, fade_duration)
	tween.tween_interval(visible_duration)

	tween.tween_property(self, "modulate:a", 0.0, fade_duration)
	tween.tween_callback(hide)
