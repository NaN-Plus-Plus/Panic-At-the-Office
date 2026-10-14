extends Control

@export var popUpWindow: BasePopUpWindow
@export var startingGameWindow: Control

@onready var quitSound: AudioStreamPlayer = $AudioStreamPlayer2

func _on_play_pressed() -> void:
	startingGameWindow.visible = true

func _on_quit_pressed() -> void:
	quitSound.play()
