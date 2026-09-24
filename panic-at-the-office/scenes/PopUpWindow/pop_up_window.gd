extends Control


@onready var quit: Control = $MarginContainer/VBoxContainer/Types/Quit

@onready var yes: TextureButton = $MarginContainer/VBoxContainer/Buttons/Ok
@onready var no: TextureButton = $MarginContainer/VBoxContainer/Buttons/Cancer

enum ConfirmationAction {
	NONE,
	QUIT,
	CLOSE
}

var current_action: ConfirmationAction = ConfirmationAction.NONE
	
	
func close_window() -> void:
	visible = false
	quit.visible = false
	get_tree().paused = false
	

func _on_ok_pressed() -> void:
	match current_action:
		
		ConfirmationAction.QUIT:
			get_tree().quit()

		ConfirmationAction.NONE:
			return
			
	close_window()
	current_action = ConfirmationAction.NONE

func _on_cancer_pressed() -> void:
	close_window()
