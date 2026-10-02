extends Sprite2D

@onready var interaction_area: InteractionArea = $InteractionArea
@onready var interaction_shape: CollisionShape2D = $InteractionArea/Telephone

var used := false

signal requested_backrooms

func _ready() -> void:
	interaction_shape.disabled = true


func work() -> void:
	if not used:
		interaction_shape.set_deferred("disabled", false)


func _interact() -> void:
	if used:
		return

	used = true
	interaction_shape.set_deferred("disabled", true)
	InteractionManager.unregister_area(interaction_area)
	await Globals.start_dialogue("Telephone")
	requested_backrooms.emit()
