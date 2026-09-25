extends Control

@onready var popUpWindow: Control = $PopUpWindow


func _on_easy_pressed() -> void:
	popUpWindow.current_action = popUpWindow.ConfirmationAction.PLAY
	popUpWindow.play.visible = true
	popUpWindow.visible = true


func _on_normal_pressed() -> void:
	popUpWindow.current_action = popUpWindow.ConfirmationAction.PLAY
	popUpWindow.play.visible = true
	popUpWindow.visible = true


func _on_hard_pressed() -> void:
	popUpWindow.current_action = popUpWindow.ConfirmationAction.PLAY
	popUpWindow.play.visible = true
	popUpWindow.visible = true
