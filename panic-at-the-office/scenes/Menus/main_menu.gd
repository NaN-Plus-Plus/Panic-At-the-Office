extends Control

@onready var popUpWindow: Control = $PopUpWindow

func _on_play_pressed() -> void:
	popUpWindow.current_action = popUpWindow.ConfirmationAction.PLAY
	popUpWindow.play.visible = true
	popUpWindow.visible = true

func _on_quit_pressed() -> void:
	popUpWindow.current_action = popUpWindow.ConfirmationAction.QUIT
	popUpWindow.quit.visible = true
	popUpWindow.visible = true
