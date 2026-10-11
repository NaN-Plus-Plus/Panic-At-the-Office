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

@onready var npc_parent: Node2D = $Npc
@onready var toriScene: PackedScene = preload("res://characters/Tori/Tori.tscn")
@onready var toyaScene: PackedScene = preload("res://characters/Toya/Toya.tscn")

const TERRAIN_SET := 0
const WALL_TERRAIN := 0
const FLOOR_TERRAIN := 1
const EXIT_TERRAIN := 2
const NPC_SAFE_SPAWN_CLEARANCE := 100.0

var maze := []
var exit_cell: Vector2i
var spawn_cells: Array
var object_scenes: Array[PackedScene] = []
var deco_textures: Array[Texture2D] = []
var occupied_cells: Dictionary = {}

func _ready() -> void:
	if Globals.isFirstTime > 0:
		Dialogic.VAR.tori_met_previous_cycle = Dialogic.VAR.tori_met
		Dialogic.VAR.toya_met_previous_cycle = Dialogic.VAR.toya_met
	else:
		Dialogic.VAR.tori_met_previous_cycle = false
		Dialogic.VAR.toya_met_previous_cycle = false

	Dialogic.VAR.tori_met = false
	Dialogic.VAR.toya_met = false
	Dialogic.VAR.tori_invited = false
	Dialogic.VAR.toya_invited = false
	GiftHUD.count = 1
	Dialogic.VAR.foundBoth = false
	GiftHUD.isVisible = false
	GiftHUD.node.visible = false
	Globals.biom = self
	Globals.isFirstTime += 1
	Dialogic.VAR.isSecondTime = Globals.isFirstTime > 1
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
	spawn_npc_1()
	spawn_npc_2()
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
	
	var floor_cells: Array[Vector2i]
	var wall_cells: Array[Vector2i]
	var exit_cells: Array[Vector2i]
	
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
	
	for cell in floor_cells:
		if cell.x > 5 or cell.y > 5:
			spawn_cells.append([cell, randf()])


func spawn_monsters():
	var monster_proportional_amount: float
	var monster_amount: int
	var tile_size: Vector2 = tile_map_layer.tile_set.tile_size
	
	match Globals.difficulty:
		Globals.difficulty_enum.EASY:
			monster_proportional_amount = 0.07
		Globals.difficulty_enum.NORMAL:
			monster_proportional_amount = 0.1
		Globals.difficulty_enum.HARD:
			monster_proportional_amount = 0.13
	monster_amount = ceil(monster_proportional_amount * spawn_cells.size())
	
	var available_spawn_cells: Array = []
	for cell in spawn_cells:
		var map_cell := cell[0] as Vector2i
		if not occupied_cells.has(map_cell) and not _is_npc_safe_spawn_cell(map_cell, tile_size):
			available_spawn_cells.append(cell)

	available_spawn_cells.sort_custom(func (a, b): return a[1] < b[1])
	for cell in available_spawn_cells.slice(0, monster_amount):
		var monster: WireMonster = monster_scene.instantiate()
		get_parent().add_child.call_deferred(monster)
		monster.global_position = tile_size * (cell[0] as Vector2) + tile_size * Vector2(randf_range(0.1, 0.9), randf_range(0.1, 0.9))
		occupied_cells[cell[0]] = true


func _is_npc_safe_spawn_cell(cell: Vector2i, tile_size: Vector2) -> bool:
	var cell_position := tile_map_layer.to_global(tile_map_layer.map_to_local(cell))
	var max_offset := tile_size.length() * 0.5
	for npc in get_tree().get_nodes_in_group("npc_safe_zone"):
		if npc is Node2D and npc.has_method("get_safe_zone_radius") and npc.global_position.distance_to(cell_position) <= npc.call("get_safe_zone_radius") + max_offset + NPC_SAFE_SPAWN_CLEARANCE:
			return true
	return false


func get_available_floor_cells() -> Array[Vector2i]:
	var cells: Array[Vector2i] = []
	for r in range(ROWS):
		for c in range(COLS):
			var cell := Vector2i(c, r)
			if maze[r][c] == 0 and cell != exit_cell and not occupied_cells.has(cell):
				cells.append(cell)
	cells.shuffle()
	return cells


func random_offset_in_tile(tile_size: Vector2) -> Vector2:
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
	
	var tile_size: Vector2 = tile_map_layer.tile_set.tile_size
	var available_cells := get_available_floor_cells()
	var amount = min(object_count, available_cells.size())
	
	for i in range(amount):
		var cell = available_cells[i]
		occupied_cells[cell] = true
		
		var scene: PackedScene = object_scenes.pick_random()
		var obj = scene.instantiate()
		object_parent.add_child.call_deferred(obj)
		
		var base_pos = tile_size * (Vector2(cell)) + tile_size * 0.5
		obj.global_position = base_pos + random_offset_in_tile(tile_size)
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
	
	var tile_size: Vector2 = tile_map_layer.tile_set.tile_size
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
		sprite.global_position = base_pos + random_offset_in_tile(tile_size)
		sprite.rotation = randf_range(0.0, TAU)

func spawn_npc_1() -> Node2D:
	return spawn_npc(toriScene)


func spawn_npc_2() -> Node2D:
	return spawn_npc(toyaScene)


func spawn_npc(scene: PackedScene) -> Node2D:
	if scene == null:
		push_warning("Nie przypisano sceny NPC!")
		return null

	var available_cells := get_available_floor_cells()

	if available_cells.is_empty():
		push_warning("Brak wolnych kafelków dla NPC!")
		return null

	var cell: Vector2i = available_cells.pick_random()
	occupied_cells[cell] = true

	var npc := scene.instantiate() as Node2D

	var base_pos := tile_map_layer.to_global(
		tile_map_layer.map_to_local(cell)
	)

	npc_parent.add_child(npc)
	npc.global_position = base_pos

	return npc
