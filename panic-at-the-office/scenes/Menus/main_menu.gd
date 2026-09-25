extends Control


@export var popUpWindow: BasePopUpWindow
@export var startingGameWindow: Control


func _on_play_pressed() -> void:
	startingGameWindow.visible = true


func _on_quit_pressed() -> void:
	popUpWindow.visible = true
