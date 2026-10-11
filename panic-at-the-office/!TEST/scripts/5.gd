extends Node2D

@onready var drops: Node2D = $Drops
@onready var mc: Player = $Mc
@onready var mc_sprite: Sprite2D = $Mc/Copy

func _ready() -> void:
	Globals.player.speed = 100
	drops.start_spawning()

	var mat := mc_sprite.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("shaking", true)

func _exit_tree() -> void:
	Globals.player.speed = 200
