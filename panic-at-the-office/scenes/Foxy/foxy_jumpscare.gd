extends AnimatedSprite2D

@export var fnaf2_jumpscare_audio: AudioStreamPlayer

@onready var main_menu_uid: String = "uid://ct74rp67mvud3"

func _ready() -> void:
	animation_finished.connect(back_to_main_menu)
	
	fnaf2_jumpscare_audio.play(0.26)

func back_to_main_menu():
	get_tree().change_scene_to_file(main_menu_uid)
