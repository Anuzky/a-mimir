extends Node

signal game_won

const rows = 5
const cols = 5

var solution = []
var top_nums = []
var left_nums = []

@onready var grid : TileMapLayer = $ColorRect/TileMap 
@onready var left_nums_grid : GridContainer = $LeftNumbers 
@onready var top_nums_grid : GridContainer = $TopNumbers 

func _ready() -> void:
	randomize() 
	
	generate_random_solution()
	add_numbers()
	
func generate_random_solution():
	solution.clear()
	left_nums.clear()
	top_nums.clear()
	
	for i in range(rows):
		left_nums.append([])
	for i in range(cols):
		top_nums.append([])
		
	for row in range(rows):
		var current_row = []
		for col in range(cols):
			current_row.append(randi() % 2) 
		solution.append(current_row)

func add_numbers():
	for row in range(rows):
		var last_val = 0
		for val in solution[row]:
			if val == 1:
				if last_val == 0:
					left_nums[row].append(1)
				else:
					left_nums[row][-1] += 1
			last_val = val
		
		if left_nums[row].is_empty():
			left_nums[row].append(0)
	
	for col in range(cols):
		var last_val = 0
		for row in range(rows):
			if solution[row][col] == 1:
				if last_val == 0:
					top_nums[col].append(1)
				else:
					top_nums[col][-1] += 1
			last_val = solution[row][col]
			
		if top_nums[col].is_empty():
			top_nums[col].append(0)
		
	for row in range(rows):
		var label = left_nums_grid.get_child(row)
		label.text = ""
		for num in left_nums[row]:
			label.text += str(num) + ' '
		label.text = label.text.strip_edges()

	for col in range(cols):
		var label = top_nums_grid.get_child(col)
		label.text = ""
		for num in top_nums[col]:
			label.text += str(num) + '\n'
		label.text = label.text.strip_edges() 

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		var mouse_pos = get_viewport().get_mouse_position()
		var tile_pos = grid.local_to_map(grid.to_local(mouse_pos))
		
		if tile_pos.x >= 0 and tile_pos.x < cols and tile_pos.y >= 0 and tile_pos.y < rows:
			if grid.get_cell_source_id(tile_pos) == -1:
				grid.set_cell(tile_pos, 0, Vector2i(0,0))
			else:
				grid.set_cell(tile_pos, -1, Vector2i(-1,-1))
				
			if is_solved():
				print("¡Ganaste!")
				game_won.emit() 
			
func is_solved():
	for row in range(rows):
		for col in range(cols):
			var current_cell = grid.get_cell_source_id(Vector2i(col,row))
			var correct_cell = solution[row][col]
			
			if current_cell == -1 and correct_cell != 0:
				return false
			if current_cell == 0 and correct_cell != 1:
				return false
				
	return true 
