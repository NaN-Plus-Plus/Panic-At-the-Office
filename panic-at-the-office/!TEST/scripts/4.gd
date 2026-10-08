extends Node2D

@onready var video_stream_player: VideoStreamPlayer = $CanvasLayer/Control/VideoStreamPlayer

func _ready() -> void:
	video_stream_player.finished.connect(_on_video_finished)

func _on_video_finished() -> void:
	var target: String = Globals.return_scene_path
	get_tree().change_scene_to_file.call_deferred(target)
