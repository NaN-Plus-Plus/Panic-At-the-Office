extends Node2D
class_name Biom

@onready var tileMap: TileMapLayer = $TileMapLayer

var ROWS := 25
var COLS := 25
const WALL := Vector2i(0, 0)
const PATH := Vector2i(8, 0)

var maze := []


func _ready() -> void:
	generate_maze()


func generate_maze():
	reset_maze()
	
	var start_row = 1
	var start_col = 1
	maze[start_row][start_col] = 0
	
	carve_path(start_row, start_col)
	print(maze)
	draw_maze()
	
	
func reset_maze():
	maze = []
	
	for r in range(ROWS):
		var row = []
		for c in range(COLS):
			row.append(1)
		maze.append(row)
		print(maze)


func carve_path(row, col):
	var directions = [
		[-2, 0], # Up
		[0, 2],  # Right
		[2, 0],  # Down
		[0, -2]  # Left
	]
	
	directions.shuffle()
	
	for dir in directions:
		var dr = dir[0]
		var dc = dir[1]
		
		var new_row = row + dr
		var new_col = col + dc
		
		if (
			new_row > 0 and 
			new_row < ROWS - 1 and 
			new_col > 0 and
			new_col < COLS - 1 and 
			maze[new_row][new_col] == 1
		):
			maze[new_row][new_col] = 0
			maze[row + dr / 2][col + dc / 2] = 0
			
			carve_path(new_row, new_col)
			

func draw_maze():
	tileMap.clear()

	for r in range(ROWS):
		for c in range(COLS):
			var tile_type = WALL if maze[r][c] == 1 else PATH
			tileMap.set_cell(Vector2i(c, r), 0, tile_type)
