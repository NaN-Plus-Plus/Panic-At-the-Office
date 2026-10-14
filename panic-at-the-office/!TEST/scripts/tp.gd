extends Area2D

@onready var thing: AnimatedSprite2D = $"../Thing"
@onready var mc: Player = $"../Mc"

var triggered := false

func _ready():
	body_entered.connect(on_body_entered)

func on_body_entered(body: Node2D):
	if triggered or not body is Player:
		return
	triggered = true

	mc.set_physics_process(false)
	mc.velocity = Vector2.ZERO
	
	thing.sprite_frames.set_animation_loop("move", false)
	thing.play("move")
	await thing.animation_finished
	await get_tree().create_timer(1.0).timeout

	mc.set_physics_process(true)

	var target: String = Globals.return_scene_path
	get_tree().change_scene_to_file.call_deferred(target)
