extends BasePopUpWindow


func _on_ok_pressed() -> void:
	super._on_cancer_pressed()
	await LoadingScreen.show_loading("Main")
	get_tree().change_scene_to_file("res://scenes/Maze/Main.tscn")
	await LoadingScreen.hide_loading()
