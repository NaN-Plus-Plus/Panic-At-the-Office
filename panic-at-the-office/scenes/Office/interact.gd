extends Node2D

@export var bob_distance := 4.0
@export var bob_time := 0.5
@export var fade_time := 0.2
@export var one_shot := true
@export_multiline var text := ""
@export var type_speed := 40.0
@export var slide_distance := 60.0
@export var slide_time := 0.35

@onready var arrow: Sprite2D = $Sprite2D
@onready var area: Area2D = $Area2D
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var panel: Panel = $CanvasLayer/Panel
@onready var label: Label = $CanvasLayer/Panel/Label
@onready var button: Button = $CanvasLayer/Panel/Button

var _bob_tween: Tween
var _panel_tween: Tween
var _button_tween: Tween
var _used := false
var _closing := false
var _panel_base_y: float
var _player: Node
var _player_mode: Node.ProcessMode

func _ready() -> void:
	canvas_layer.hide()
	button.hide()
	label.text = text
	label.visible_characters = 0
	_panel_base_y = panel.position.y
	area.body_entered.connect(_on_body_entered)
	button.pressed.connect(_close_panel)
	_show_arrow()

func _show_arrow() -> void:
	arrow.show()
	arrow.modulate.a = 1.0
	var base_y := arrow.position.y
	_bob_tween = create_tween().set_loops()
	_bob_tween.tween_property(arrow, "position:y", base_y - bob_distance, bob_time) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_bob_tween.tween_property(arrow, "position:y", base_y + bob_distance, bob_time) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _hide_arrow() -> void:
	if _bob_tween:
		_bob_tween.kill()
	var t := create_tween()
	t.tween_property(arrow, "modulate:a", 0.0, fade_time)
	t.tween_callback(arrow.hide)

func _freeze_player(body: Node) -> void:
	_player = body
	_player_mode = body.process_mode
	body.process_mode = Node.PROCESS_MODE_DISABLED

func _unfreeze_player() -> void:
	if is_instance_valid(_player):
		_player.process_mode = _player_mode
	_player = null

func _show_button() -> void:
	if _closing:
		return
	button.modulate.a = 0.0
	button.show()
	if _button_tween:
		_button_tween.kill()
	_button_tween = create_tween()
	_button_tween.tween_property(button, "modulate:a", 1.0, 0.25)

func _open_panel() -> void:
	button.hide()
	label.text = text
	label.visible_characters = 0
	panel.position.y = _panel_base_y + slide_distance
	panel.modulate.a = 0.0
	canvas_layer.show()

	if _panel_tween:
		_panel_tween.kill()
	_panel_tween = create_tween().set_parallel(true)
	_panel_tween.tween_property(panel, "position:y", _panel_base_y, slide_time) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	_panel_tween.tween_property(panel, "modulate:a", 1.0, slide_time * 0.6)

	var chars := text.length()
	if chars > 0:
		_panel_tween.tween_property(label, "visible_characters", chars, chars / type_speed) \
			.set_delay(slide_time * 0.5)
	_panel_tween.chain().tween_callback(_show_button)

func _close_panel() -> void:
	if _closing:
		return
	_closing = true
	if _panel_tween:
		_panel_tween.kill()
	if _button_tween:
		_button_tween.kill()
	button.hide()
	label.visible_characters = -1
	_panel_tween = create_tween().set_parallel(true)
	_panel_tween.tween_property(panel, "position:y", _panel_base_y + slide_distance, slide_time) \
		.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	_panel_tween.tween_property(panel, "modulate:a", 0.0, slide_time)
	_panel_tween.chain().tween_callback(_on_panel_closed)

func _on_panel_closed() -> void:
	canvas_layer.hide()
	_closing = false
	_unfreeze_player()

func _on_body_entered(body: Node2D) -> void:
	if _used or not body.is_in_group("player"):
		return
	if one_shot:
		_used = true
		area.set_deferred("monitoring", false)
	_hide_arrow()
	if text.strip_edges().is_empty():
		return
	_freeze_player(body)
	_open_panel()
