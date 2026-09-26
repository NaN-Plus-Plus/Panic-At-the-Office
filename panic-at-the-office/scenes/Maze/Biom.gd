extends Node2D
class_name Biom


@export var tile_map_layer: TileMapLayer

@onready var ROWS := Globals.rows
@onready var COLS := Globals.cols
@onready var monster_scene: PackedScene = preload("uid://2mrx4ulwqgfi")

const TERRAIN_SET := 0
const WALL_TERRAIN := 0
const FLOOR_TERRAIN := 1
const EXIT_TERRAIN := 2

var maze := []
var exit_cell: Vector2i
var spawn_cells: Array

func _ready() -> void:
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
	spawn_monsters()


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
	
	spawn_cells.sort_custom(func (a, b): return a[1] < b[1])
	spawn_cells = spawn_cells.slice(0, monster_amount)
	for cell in spawn_cells:
		var monster: WireMonster = monster_scene.instantiate()
		get_parent().add_child.call_deferred(monster)
		monster.global_position = tile_size * (cell[0] as Vector2) + tile_size * 0.5
