extends Node2D
class_name Biom

@export var tile_map_layer: TileMapLayer

@export var object_parent: Node
@export_dir var objects_folder: String
@export var object_count: int = 100

@export var deco_parent: Node
@export_dir var deco_folder: String
@export var deco_count: int = 200

@onready var ROWS := Globals.rows
@onready var COLS := Globals.cols

@onready var monster_scene: PackedScene = preload("uid://2mrx4ulwqgfi")
@onready var office_wall: PackedScene = preload("uid://clkuxm8mdm1du")
@onready var tile_size: Vector2 = tile_map_layer.tile_set.tile_size
@onready var wall_deco: PackedScene = preload("uid://cwyil1lxinv1y")

const TERRAIN_SET := 0
const WALL_TERRAIN := 3
const FLOOR_TERRAIN := 1
const EXIT_TERRAIN := 2

var maze := []
var exit_cell: Vector2i
var floor_cells: Array[Vector2i]
var wall_cells: Array[Vector2i]
var exit_cells: Array[Vector2i]
var top_wall_cells: Array[Vector2i]
var object_scenes: Array[PackedScene] = []
var deco_textures: Array[Texture2D] = []
var occupied_cells: Dictionary = {}

func _ready() -> void:
	Globals.biom = self
	generate_maze()

func generate_maze():
	reset_maze()
	
	var start_row = 1
	var start_col = 1
	maze[start_row][start_col] = 0
	
	carve_path(start_row, start_col)
	#print(maze)
	create_exit()
	draw_maze()
	spawn_walls()
	spawn_wall_deco()
	spawn_monsters()
	spawn_objects()
	spawn_deco()

func reset_maze():
	maze = []
	
	for r in range(ROWS):
		var row = []
		for c in range(COLS):
			row.append(1)
		maze.append(row)
		#print(maze)

func carve_path(start_row, start_col):
	var stack = [Vector2i(start_row, start_col)]
	
	while not stack.is_empty():
		var current: Vector2i = stack.back()
		
		var row = current.x
		var col = current.y
		
		var directions = [
			Vector2i(-2, 0), # Up
			Vector2i(0, 2),  # Right
			Vector2i(2, 0),  # Down
			Vector2i(0, -2)  # Left
		]
		
		directions.shuffle()
		
		var carved = false
		
		for dir in directions:
			var new_row = row + dir.x
			var new_col = col + dir.y
			
			if (
				new_row > 0 and
				new_row < ROWS - 1 and
				new_col > 0 and
				new_col < COLS - 1 and
				maze[new_row][new_col] == 1
			):
				maze[new_row][new_col] = 0
				maze[row + dir.x / 2][col + dir.y / 2] = 0
				
				stack.append(Vector2i(new_row, new_col))
				carved = true
				break
		
		if not carved:
			stack.pop_back()


func create_exit():
	var possible_exits: Array[Vector2i] = []
	
	for r in range(1, ROWS - 1):
		if maze[r][COLS - 2] == 0:
			possible_exits.append(Vector2i(COLS - 1, r))
			
	for c in range(1, COLS - 1):
		if maze[ROWS - 2][c] == 0:
			possible_exits.append(Vector2i(c, ROWS - 1))
	
	exit_cell = possible_exits.pick_random()


func draw_maze():
	tile_map_layer.clear()
	
	floor_cells.clear()
	wall_cells.clear()
	exit_cells.clear()
	
	for r in range(ROWS):
		for c in range(COLS):
			var cell := Vector2i(c, r)
			
			if cell == exit_cell:
				exit_cells.append(cell)
			elif maze[r][c] == 0:
				floor_cells.append(Vector2i(c, r))
			else:
				wall_cells.append(Vector2i(c, r))
	
	tile_map_layer.set_cells_terrain_connect(
		floor_cells,
		TERRAIN_SET,
		FLOOR_TERRAIN
	)
	
	tile_map_layer.set_cells_terrain_connect(
		wall_cells,
		TERRAIN_SET,
		WALL_TERRAIN
	)
	
	tile_map_layer.set_cells_terrain_connect(
		exit_cells,
		TERRAIN_SET,
		EXIT_TERRAIN
	)


func spawn_walls():
	top_wall_cells.clear()
	var bottom_wall_cells: Array
	var left_wall_cells: Array
	var right_wall_cells: Array
	
	
	for cell in floor_cells:
		if not (cell + Vector2i(0, -1)) in floor_cells and not (cell + Vector2i(0, -1)) in exit_cells:
			top_wall_cells.append(cell)
		
		if not (cell + Vector2i(0, 1)) in floor_cells and not (cell + Vector2i(0, 1)) in exit_cells:
			bottom_wall_cells.append(cell)
		
		if not (cell + Vector2i(-1, 0)) in floor_cells and not (cell + Vector2i(-1, 0)) in exit_cells:
			left_wall_cells.append(cell)
		
		if not (cell + Vector2i(1, 0)) in floor_cells and not (cell + Vector2i(1, 0)) in exit_cells:
			right_wall_cells.append(cell)
	
	for cell in top_wall_cells:
		var wall: OfficeWall = office_wall.instantiate()
		get_parent().y_sort.add_child.call_deferred(wall)
		wall.global_position = tile_size * Vector2(cell)
		wall.set_deferred("length", int(tile_size.x) + 1)
	
	for cell in bottom_wall_cells:
		var wall: OfficeWall = office_wall.instantiate()
		get_parent().y_sort.add_child.call_deferred(wall)
		wall.global_position = tile_size * Vector2(cell) + Vector2(7, tile_size.y)
		wall.set_deferred("length", int(tile_size.x) + 1)
	
	for cell in left_wall_cells:
		var wall: OfficeWall = office_wall.instantiate()
		get_parent().y_sort.add_child.call_deferred(wall)
		wall.global_position = tile_size * Vector2(cell) + Vector2(0, tile_size.y)
		wall.set_deferred("length", int(tile_size.x) + 1)
		wall.set_deferred("axis", "Vertical")
	
	for cell in right_wall_cells:
		var wall: OfficeWall = office_wall.instantiate()
		get_parent().y_sort.add_child.call_deferred(wall)
		wall.global_position = tile_size * Vector2(cell) + Vector2(tile_size.x, tile_size.y - 7)
		wall.set_deferred("length", int(tile_size.x) + 1)
		wall.set_deferred("axis", "Vertical")


func spawn_wall_deco():
	for cell in top_wall_cells:
		if randf() < 0.3:
			var deco = wall_deco.instantiate() as Sprite2D
			get_parent().y_sort.add_child.call_deferred(deco)
			deco.global_position = tile_size * Vector2(cell) + Vector2(tile_size.x / 2, 4)
			deco.frame = randi_range(0, 6)
			deco.offset = Vector2(randf_range(-tile_size.x * 0.35, tile_size.x * 0.35), randf_range(-32, -44))


func spawn_monsters():
	var monster_proportional_amount: float
	var monster_amount: int
	var spawn_cells: Array[Vector2i]
	
	for cell in floor_cells:
		if cell.x > 5 or cell.y > 5:
			spawn_cells.append(cell)
	
	match Globals.difficulty:
		Globals.difficulty_enum.EASY:
			monster_proportional_amount = 0.07
		Globals.difficulty_enum.NORMAL:
			monster_proportional_amount = 0.1
		Globals.difficulty_enum.HARD:
			monster_proportional_amount = 0.13
	monster_amount = ceil(monster_proportional_amount * spawn_cells.size())
	
	spawn_cells.shuffle()
	spawn_cells = spawn_cells.slice(0, monster_amount)
	for cell in spawn_cells:
		var monster: WireMonster = monster_scene.instantiate()
		get_parent().y_sort.add_child.call_deferred(monster)
		monster.global_position = tile_size * (cell as Vector2) + tile_size * Vector2(randf_range(0.1, 0.9), randf_range(0.1, 0.9))
		occupied_cells[cell] = true


func get_available_floor_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for r in range(ROWS):
		for c in range(COLS):
			var cell := Vector2i(c, r)
			if maze[r][c] == 0 and cell != exit_cell and not occupied_cells.has(cell):
				cells.append(cell)
	cells.shuffle()
	return cells

func random_offset_in_tile() -> Vector2:
	var margin := 0.15
	var rx := randf_range(-0.5 + margin, 0.5 - margin)
	var ry := randf_range(-0.5 + margin, 0.5 - margin)
	return Vector2(rx * tile_size.x, ry * tile_size.y)

func load_object_scenes():
	object_scenes.clear()
	
	var dir := DirAccess.open(objects_folder)

	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tscn"):
			var path := objects_folder.path_join(file_name)
			var scene: PackedScene = load(path)
			if scene:
				object_scenes.append(scene)
		file_name = dir.get_next()
	dir.list_dir_end()

func spawn_objects():

	load_object_scenes()
	
	var available_cells := get_available_floor_cells()
	var amount = min(object_count, available_cells.size())
	
	for i in range(amount):
		var cell = available_cells[i]
		occupied_cells[cell] = true
		
		var scene: PackedScene = object_scenes.pick_random()
		var obj = scene.instantiate()
		object_parent.add_child.call_deferred(obj)
		
		var base_pos = tile_size * (Vector2(cell)) + tile_size * 0.5
		obj.global_position = base_pos + random_offset_in_tile()
		if obj is Node2D:
			obj.rotation = randf_range(0.0, TAU)

func load_deco_textures():
	deco_textures.clear()
	
	var dir := DirAccess.open(deco_folder)
	
	dir.list_dir_begin()
	var file_name := dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.get_extension().to_lower() == "png":
			var path := deco_folder.path_join(file_name)
			var tex: Texture2D = load(path)
			if tex:
				deco_textures.append(tex)
		file_name = dir.get_next()
	dir.list_dir_end()

func spawn_deco():
	load_deco_textures()
	
	var available_cells := get_available_floor_cells()
	var amount = min(deco_count, available_cells.size())
	
	for i in range(amount):
		var cell = available_cells[i]
		occupied_cells[cell] = true
		
		var tex: Texture2D = deco_textures.pick_random()
		var sprite := Sprite2D.new()
		sprite.texture = tex
		deco_parent.add_child.call_deferred(sprite)
		
		var base_pos = tile_size * (Vector2(cell)) + tile_size * 0.5
		sprite.global_position = base_pos + random_offset_in_tile()
		sprite.rotation = randf_range(0.0, TAU)
