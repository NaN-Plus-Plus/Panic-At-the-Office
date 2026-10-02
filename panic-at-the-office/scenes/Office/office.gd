extends Sprite2D

@onready var start: CollisionShape2D = $Story/Start/Start
@onready var telephone: CollisionShape2D = $Story/Telephone/Telephone/InteractionArea/Telephone
@onready var backrooms: CollisionShape2D = $Story/Backrooms/Backrooms
@onready var telephoneScene: Sprite2D = $Story/Telephone/Telephone
var start_used := false

func _ready():
	Globals.player.speed = 100
	
	if Globals.is_story:
		start.disabled = false
		backrooms.disabled = true
	else:
		start.disabled = true
		backrooms.disabled = false
		
	telephone.disabled = true
	
	telephoneScene.requested_backrooms.connect(backroomsFunc)

func _exit_tree():
	Globals.player.speed = 200


func _on_backrooms_body_entered(body: Node2D) -> void:
	if Globals.is_story:
		if body.is_in_group("player"):
			Globals.pending_dialogue = "IntoBackrooms"
			await LoadingScreen.show_loading("Main")
			get_tree().call_deferred("change_scene_to_file", "res://scenes/Maze/Main.tscn")
	else:
		if body.is_in_group("player"):
			await LoadingScreen.show_loading("???")
			get_tree().call_deferred("change_scene_to_file", "res://scenes/Maze/Main.tscn")
			await LoadingScreen.hide_loading()


func _on_start_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not start_used:
		start_used = true
		start.set_deferred("disabled", true)
		telephoneScene.work()
		start_dialogue("Prolog")


func start_dialogue(timeline: String):
	InteractionManager.freeze_world()
	Dialogic.start(timeline)
	await Dialogic.timeline_ended
	InteractionManager.unfreeze_world()


func backroomsFunc():
	backrooms.set_deferred("disabled", false)
