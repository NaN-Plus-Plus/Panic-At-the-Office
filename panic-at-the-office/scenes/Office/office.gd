extends Sprite2D

@onready var start: CollisionShape2D = $Story/Start/Start
@onready var telephone: CollisionShape2D = $Story/Telephone/Telephone/InteractionArea/Telephone
@onready var backrooms: CollisionShape2D = $Story/Backrooms/Backrooms
@onready var telephoneScene: Sprite2D = $Story/Telephone/Telephone

var start_used := false
var _saved_materials := {}

func _ready():
	Globals.player.speed = 100
	_disable_silhouette()

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
	_restore_silhouette()

func _disable_silhouette():
	for node in Globals.player.find_children("*", "CanvasItem", true, false):
		var mat := (node as CanvasItem).material as ShaderMaterial
		if mat and mat.shader and mat.shader.code.contains("silhouette_color"):
			_saved_materials[node] = mat
			node.material = null

func _restore_silhouette():
	for node in _saved_materials:
		if is_instance_valid(node):
			node.material = _saved_materials[node]
	_saved_materials.clear()


func _on_backrooms_body_entered(body: Node2D) -> void:
	if Globals.is_story:
		if body.is_in_group("player"):
			Globals.whereAmI = "Backrooms"
			Globals.pending_dialogue = "IntoBackrooms"
			await LoadingScreen.show_loading("Main")
			#get_tree().call_deferred("change_scene_to_file", "res://scenes/Maze/Main.tscn")
			get_tree().change_scene_to_file("res://scenes/Maze/Main.tscn")
			await LoadingScreen.hide_loading()
	else:
		if body.is_in_group("player"):
			Globals.whereAmI = "Backrooms"
			await LoadingScreen.show_loading("???")
			#get_tree().call_deferred("change_scene_to_file", "res://scenes/Maze/Main.tscn")
			get_tree().change_scene_to_file("res://scenes/Maze/Main.tscn")
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
