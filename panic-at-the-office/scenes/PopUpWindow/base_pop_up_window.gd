extends Control
class_name BasePopUpWindow


func close_window() -> void:
	visible = false
	get_tree().paused = false


func _on_ok_pressed() -> void:
	close_window()


func _on_cancer_pressed() -> void:
	close_window()
