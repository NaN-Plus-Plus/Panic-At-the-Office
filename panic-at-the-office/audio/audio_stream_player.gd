extends AudioStreamPlayer

@export var target: Node2D
@export var max_distance: float = 1500.0
@export var min_distance: float = 100.0
@export var quiet_db: float = -40.0
@export var loud_db: float = 0.0

func _process(_delta):
	if target == null or Globals.player == null:
		return

	var dist := Globals.player.global_position.distance_to(target.global_position)
	var t := 1.0 - clampf(inverse_lerp(min_distance, max_distance, dist), 0.0, 1.0)
	volume_db = lerpf(quiet_db, loud_db, t)
