extends BasePopUpWindow


func _on_ok_pressed() -> void:
	super._on_cancer_pressed()
	get_tree().quit()
