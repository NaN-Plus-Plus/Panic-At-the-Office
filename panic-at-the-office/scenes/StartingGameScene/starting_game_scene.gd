extends Control

@onready var popUpWindow: Control = $PopUpWindow


func _on_easy_pressed() -> void:
	Globals.cols = 25
	Globals.rows = 25
	popUpWindow.current_action = popUpWindow.ConfirmationAction.PLAY
	popUpWindow.play.visible = true
	popUpWindow.visible = true


func _on_normal_pressed() -> void:
	Globals.cols = 50
	Globals.rows = 50
	popUpWindow.current_action = popUpWindow.ConfirmationAction.PLAY
	popUpWindow.play.visible = true
	popUpWindow.visible = true


func _on_hard_pressed() -> void:
	Globals.cols = 100
	Globals.rows = 100
	popUpWindow.current_action = popUpWindow.ConfirmationAction.PLAY
	popUpWindow.play.visible = true
	popUpWindow.visible = true
