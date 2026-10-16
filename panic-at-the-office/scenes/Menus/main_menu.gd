extends Control

@export var popUpWindow: BasePopUpWindow
@export var startingGameWindow: Control

@onready var quitSound: AudioStreamPlayer = $AudioStreamPlayer2

func _on_play_pressed() -> void:
	startingGameWindow.visible = true

func _on_quit_pressed() -> void:
	#quitSound.play()
	get_tree().quit()


func _on_button_pressed() -> void:
	OS.shell_open("https://forms.gle/GZBhVUXcmuMoN26N8")
	
func _on_button_2_pressed() -> void:
	OS.shell_open("https://forms.gle/NqFrjQ9vEf8ZgwQd7")
