extends BasePopUpWindow


func _on_ok_pressed() -> void:
	super._on_cancer_pressed()
	await LoadingScreen.show_loading("Office")
	get_tree().change_scene_to_file("res://scenes/Office/Office.tscn")
	await LoadingScreen.hide_loading()
