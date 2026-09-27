extends Control

@export var confetti_parent: Node
@export_dir var confetti_folder: String
@export var confetti_count: int = 300
@export var fall_speed_min: float = 100.0
@export var fall_speed_max: float = 300.0

var confetti_textures: Array[Texture2D] = []
var confetti_sprites: Array[Sprite2D] = []
var confetti_speeds: Array[float] = []

func _ready():
	spawn_confetti()

func _process(delta: float) -> void:
	for i in confetti_sprites.size():
		var sprite := confetti_sprites[i]
		sprite.position.y += confetti_speeds[i] * delta
		
		if sprite.position.y > get_viewport_rect().size.y + 50:
			sprite.position.y = -50
			sprite.position.x = randf_range(0.0, get_viewport_rect().size.x)

func load_confetti_textures():
	confetti_textures.clear()
	
	var dir := DirAccess.open(confetti_folder)
	
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.get_extension().to_lower() == "png":
			var path := confetti_folder.path_join(file_name)
			var tex: Texture2D = load(path)
			if tex:
				confetti_textures.append(tex)
		file_name = dir.get_next()
	dir.list_dir_end()

func spawn_confetti():
	load_confetti_textures()
	
	var viewport_size := get_viewport_rect().size
	
	for i in range(confetti_count):
		var tex: Texture2D = confetti_textures.pick_random()
		var sprite := Sprite2D.new()
		sprite.texture = tex
		confetti_parent.add_child.call_deferred(sprite)
		
		sprite.position = Vector2(
			randf_range(0.0, viewport_size.x),
			randf_range(-viewport_size.y, 0.0)
		)
		sprite.rotation = randf_range(0.0, TAU)
		
		confetti_sprites.append(sprite)
		confetti_speeds.append(randf_range(fall_speed_min, fall_speed_max))
