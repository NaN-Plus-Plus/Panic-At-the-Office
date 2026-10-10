extends Node2D

@onready var panel: Panel = $Panel
@onready var area_2d: Area2D = $Area2D
@onready var panel_2: Panel = $Panel2
@onready var exit: Area2D = $EXIT
@onready var canvas_layer: CanvasLayer = $CanvasLayer
@onready var pulled: Node2D = $CanvasLayer/Thing
@onready var butterflies: Node2D = $CanvasLayer/Butterflies

var triggered: bool = false

func _ready():
	Globals.player.speed = 100
	canvas_layer.hide()
	panel.hide()
	panel_2.hide()
	exit.set_deferred("monitoring", false)

func _exit_tree():
	Globals.player.speed = 200

func _on_area_2d_body_entered(body: Node2D) -> void:
	if triggered or not body.is_in_group("player"):
		return
	triggered = true
	area_2d.set_deferred("monitoring", false)

	panel.show()
	await get_tree().create_timer(2.0).timeout
	
	butterflies.start_spawning()
	canvas_layer.show()
	await shake_up()
	
	panel_2.show()
	await get_tree().create_timer(2.0).timeout
	
	exit.set_deferred("monitoring", true)

func shake_up() -> void:
	var start_y := pulled.position.y
	var max_height := 200.0
	var steps := 6
	var back_amount := 10.0
	var step_size := max_height / steps

	var tween := create_tween()
	for i in steps:
		var forward := start_y - step_size * (i + 1)
		tween.tween_property(pulled, "position:y", forward, 0.12)
		if i < steps - 1:
			tween.tween_property(pulled, "position:y", forward + back_amount, 0.08)

	await tween.finished
