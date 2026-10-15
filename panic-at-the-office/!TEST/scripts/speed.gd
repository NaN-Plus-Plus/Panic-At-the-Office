extends Node2D

func _ready() -> void:
	GiftHUD.hide_gift()
	Globals.player.speed = 100

func _exit_tree() -> void:
	Globals.player.speed = 200
