extends Area2D

var triggered: bool = false

func _ready():
	body_entered.connect(on_body_entered)

func on_body_entered(body: Node2D):
	if triggered or not body is Player:
		return
	triggered = true

	var target: String = Globals.return_scene_path
	get_tree().change_scene_to_file.call_deferred(target)
