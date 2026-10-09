extends Node2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	animated_sprite_2d.sprite_frames.set_animation_loop("idle", false)
	animated_sprite_2d.play("idle")
