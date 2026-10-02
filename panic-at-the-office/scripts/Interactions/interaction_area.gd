extends Area2D
class_name InteractionArea

@export var action_name: String = "Interact"

var interact: Callable = func():
	pass


func _ready() -> void:
	var target := get_parent()
	if target and target.has_method("_interact"):
		interact = Callable(target, "_interact")


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		InteractionManager.register_area(self)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		InteractionManager.unregister_area(self)
