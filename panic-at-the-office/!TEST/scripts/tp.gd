extends Area2D

@onready var thing: AnimatedSprite2D = $"../Thing"
@onready var mc: Player = $"../Mc"
@onready var thing_con: AnimatedSprite2D = $"../ThingCon"

var triggered := false

func _ready():
	body_entered.connect(on_body_entered)
	thing_con.hide()

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

	thing_con.sprite_frames.set_animation_loop("move", false)
	thing_con.show()

	mc.sprite.animation = "walk_f"
	mc.sprite.stop()
	mc.sprite.set_frame_and_progress(0, 0.0)

	thing_con.play("move")
	await thing_con.animation_finished

	mc.set_physics_process(true)

	var target: String = Globals.return_scene_path
	get_tree().change_scene_to_file.call_deferred(target)
