extends Label

@export var hop_height := 30.0
@export var tilt_degrees := 12.0
@export var tilt_time := 0.12
@export var air_time := 0.35
@export var colors: Array[Color] = [
	Color("ffd93d"),
	Color("ff6b9d"),
	Color("6bcBff"),
	Color("7dff8a"),
]

@onready var panel_3: Panel = $"../Panel3"

var _base_y: float
var _tween: Tween
var _color_tween: Tween

func _ready() -> void:
	await get_tree().process_frame
	_base_y = position.y
	modulate = colors[0]
	panel_3.modulate = colors[0]
	_start_loop()
	_start_colors()

func _start_loop() -> void:
	_tween = create_tween().set_loops()
	_add_hop(-1)
	_add_hop(1)

func _start_colors() -> void:
	_color_tween = create_tween().set_loops()
	for i in colors.size():
		var next: Color = colors[(i + 1) % colors.size()]
		_color_tween.tween_property(self, "modulate", next, 0.7) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		_color_tween.parallel().tween_property(panel_3, "modulate", next, 0.7) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _set_corner(side: int) -> void:
	pivot_offset = Vector2(0.0 if side < 0 else size.x, size.y)

func _add_hop(side: int) -> void:
	_tween.tween_callback(_set_corner.bind(side))

	_tween.tween_property(self, "rotation_degrees", side * tilt_degrees, tilt_time) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	_tween.tween_property(self, "position:y", _base_y - hop_height, air_time) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.parallel().tween_property(self, "rotation_degrees", 0.0, air_time) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN_OUT)

	_tween.tween_property(self, "position:y", _base_y, air_time) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
