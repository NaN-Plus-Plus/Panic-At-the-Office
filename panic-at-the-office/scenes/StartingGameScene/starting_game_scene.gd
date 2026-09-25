extends Control

@export var popUpWindow: BasePopUpWindow


func _on_easy_pressed() -> void:
	Globals.cols = 21
	Globals.rows = 21
	popUpWindow.visible = true


func _on_normal_pressed() -> void:
	Globals.cols = 31
	Globals.rows = 31
	popUpWindow.visible = true


func _on_hard_pressed() -> void:
	Globals.cols = 51
	Globals.rows = 51
	popUpWindow.visible = true
