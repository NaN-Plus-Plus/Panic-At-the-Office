extends Panel

@export var drop_distance: float = 300.0
@export var drop_time: float = 0.6
@export var hold_time: float = 1.0
@export var retreat_time: float = 0.5
@export var sway_angle_deg: float = 8.0
@export var sway_cycles: int = 8

var final_position: Vector2

func _ready() -> void:
	call_deferred("_start_intro")

func _start_intro() -> void:
	pivot_offset = Vector2(size.x / 2.0, 0)
	final_position = position   
	position.y -= drop_distance
	rotation_degrees = 0
	play_intro()

func play_intro() -> void:
	var drop_tween := create_tween()
	drop_tween.tween_property(self, "position:y", final_position.y, drop_time)\
		.set_trans(Tween.TRANS_BOUNCE)\
		.set_ease(Tween.EASE_OUT)

	var sway_tween := create_tween()
	var angle := sway_angle_deg
	for i in range(sway_cycles):
		var dir := 1 if i % 2 == 0 else -1
		sway_tween.tween_property(self, "rotation_degrees", angle * dir, drop_time * 0.5)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		angle *= 0.5  
	sway_tween.tween_property(self, "rotation_degrees", 0.0, 0.3)\
		.set_trans(Tween.TRANS_SINE)

	await drop_tween.finished
	await sway_tween.finished

	await get_tree().create_timer(hold_time).timeout
	play_outro()

func play_outro() -> void:
	var tween := create_tween()
	tween.tween_property(self, "position:y", final_position.y - drop_distance, retreat_time)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_IN)
