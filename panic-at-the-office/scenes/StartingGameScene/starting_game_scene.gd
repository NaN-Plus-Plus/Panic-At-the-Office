extends Control

@export var popUpWindow: BasePopUpWindow


func _on_easy_pressed() -> void:
	Globals.cols = 20
	Globals.rows = 20
	popUpWindow.visible = true


func _on_normal_pressed() -> void:
	Globals.cols = 30
	Globals.rows = 30
	popUpWindow.visible = true


func _on_hard_pressed() -> void:
	Globals.cols = 40
	Globals.rows = 40
	popUpWindow.visible = true
