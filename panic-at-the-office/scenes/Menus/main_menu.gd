extends Control


@onready var popUpWindow: Control = $PopUpWindow
@onready var startingGameWindow: Control = $StartingGameScene


func _on_play_pressed() -> void:
	startingGameWindow.visible = true


func _on_quit_pressed() -> void:
	popUpWindow.current_action = popUpWindow.ConfirmationAction.QUIT
	popUpWindow.quit.visible = true
	popUpWindow.visible = true
