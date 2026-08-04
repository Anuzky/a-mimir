extends Node

const rows = 5 # esto era un export pero se me complica para variar el tamaño del tileset. despues veo
const cols = 5
#@export 
@onready var solution = [[1,0,0,1,1],[0,1,1,1,0],[1,1,1,1,1],[1,0,0,1,0],[0,0,1,0,1]]
var top_nums = [[],[],[],[],[]]
var left_nums = [[],[],[],[],[]]

@onready var grid : TileMapLayer = $ColorRect/TileMap 
@onready var left_nums_grid : GridContainer = $LeftNumbers 
@onready var top_nums_grid : GridContainer = $TopNumbers 
func _ready() -> void:
	#dibujar lineas grilla
	add_numbers()
	
	
func add_numbers():
	for row in range(rows):
		var last_val = 0
		print(solution)
		for val in solution[row]:
			if val == 1:
				if last_val == 0:
					if left_nums[row] == []:
						left_nums[row] = [1]
					else:
						left_nums[row].append(1)
						
				else:
					left_nums[row][-1] += 1
			last_val = val
	
	for col in range(cols):
		var last_val = 0
		for row in range(rows):
			if solution[row][col] == 1:
				if last_val == 0:
					if top_nums == []:
						top_nums[col] = [1]
					else:
						top_nums[col].append(1)
				else:
					top_nums[col][-1] += 1
			last_val = solution[row][col]
		
	for row in range(rows):
		for num in left_nums[row]:
			left_nums_grid.get_child(row).text += str(num) + ' '
		if left_nums_grid.get_child(row).text:
			left_nums_grid.get_child(row).text = left_nums_grid.get_child(row).text.substr(0,-1)
	for col in range(cols):
		for num in top_nums[col]:
			top_nums_grid.get_child(col).text += str(num) + '\n'
		if top_nums_grid.get_child(col).text:
			top_nums_grid.get_child(col).text = top_nums_grid.get_child(col).text.substr(0,-1)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		var mouse_pos = get_viewport().get_mouse_position()
		var tile_pos = grid.local_to_map(grid.to_local(mouse_pos))
		if tile_pos.x >= 0 and tile_pos.x < cols and tile_pos.y >= 0 and tile_pos.y < rows:
			if grid.get_cell_source_id(tile_pos) == -1:
				grid.set_cell(tile_pos,0,Vector2i(0,0))
			else:
				grid.set_cell(tile_pos,-1,Vector2i(-1,-1))
			if is_solved():
				print("ganaste.")
			
func is_solved():
	var won = true
	for row in range(rows):
		var output = ""
		var output2 = ""
		for col in range(cols):
			output += str(grid.get_cell_source_id(Vector2i(col,row))) + " "
			output2 += str(solution[row][col]) + " "
			if grid.get_cell_source_id(Vector2i(col,row)) == -1 and solution[row][col] != 0:
				won = false
				#break
			if grid.get_cell_source_id(Vector2i(col,row)) == 0 and solution[row][col] != 1:
				won = false
				#break
	return won
