extends Control


@onready var quit: Control = $MarginContainer/VBoxContainer/Types/Quit
@onready var play: Control = $MarginContainer/VBoxContainer/Types/Play

@onready var yes: TextureButton = $MarginContainer/VBoxContainer/Buttons/Ok
@onready var no: TextureButton = $MarginContainer/VBoxContainer/Buttons/Cancer

enum ConfirmationAction {
	NONE,
	PLAY,
	QUIT,
	CLOSE
}

var current_action: ConfirmationAction = ConfirmationAction.NONE


func close_window() -> void:
	visible = false
	get_tree().paused = false


func _on_ok_pressed() -> void:
	match current_action:
		
		ConfirmationAction.PLAY:
			await LoadingScreen.show_loading("Main")
			get_tree().change_scene_to_file("res://scenes/Maze/Main.tscn")
			await LoadingScreen.hide_loading()
			return
			
		ConfirmationAction.QUIT:
			get_tree().quit()
		
		ConfirmationAction.NONE:
			return
	
	close_window()
	current_action = ConfirmationAction.NONE


func _on_cancer_pressed() -> void:
	close_window()
