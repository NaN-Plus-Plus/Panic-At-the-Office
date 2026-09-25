extends Control

@onready var popUpWindow: Control = $PopUpWindow


func _on_easy_pressed() -> void:
	Globals.cols = 20
	Globals.rows = 20
	popUpWindow.current_action = popUpWindow.ConfirmationAction.PLAY
	popUpWindow.play.visible = true
	popUpWindow.visible = true


func _on_normal_pressed() -> void:
	Globals.cols = 30
	Globals.rows = 30
	popUpWindow.current_action = popUpWindow.ConfirmationAction.PLAY
	popUpWindow.play.visible = true
	popUpWindow.visible = true


func _on_hard_pressed() -> void:
	Globals.cols = 40
	Globals.rows = 40
	popUpWindow.current_action = popUpWindow.ConfirmationAction.PLAY
	popUpWindow.play.visible = true
	popUpWindow.visible = true
