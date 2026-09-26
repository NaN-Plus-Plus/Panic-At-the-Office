extends Node2D

func _ready():
	Globals.player.speed = 100

func _exit_tree():
	Globals.player.speed = 200
