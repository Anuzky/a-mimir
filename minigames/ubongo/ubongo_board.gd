extends Node2D

const COLS = 5
const ROWS = 5
const CELL_SIZE = 50 
var current_spawn_index = 0
var grid = []
var board_offset = Vector2(440, 148)
var next_spawn_pos = Vector2(260, 130)
var color_dark = Color(0.11, 0.13, 0.21)
var color_light = Color(0.85, 0.91, 0.93)

@onready var piece_scene = preload("res://minigames/ubongo/Ubongo_piece.tscn")

func _ready() -> void:
	randomize()
	init_grid()
	generate_puzzle()

func _draw() -> void:
	draw_rect(Rect2(board_offset, Vector2(COLS * CELL_SIZE, ROWS * CELL_SIZE)), color_dark)
	
	var thin_line = 2.0
	var thick_line = 6.0 
	
	for i in range(1, COLS):
		var x = board_offset.x + (i * CELL_SIZE)
		draw_line(Vector2(x, board_offset.y), Vector2(x, board_offset.y + ROWS * CELL_SIZE), color_light, thin_line)
		
	for i in range(1, ROWS):
		var y = board_offset.y + (i * CELL_SIZE)
		draw_line(Vector2(board_offset.x, y), Vector2(board_offset.x + COLS * CELL_SIZE, y), color_light, thin_line)

	draw_rect(Rect2(board_offset, Vector2(COLS * CELL_SIZE, ROWS * CELL_SIZE)), color_light, false, thick_line)

func init_grid() -> void:
	grid.clear()
	for y in range(ROWS):
		var row = []
		for x in range(COLS):
			row.append(0)
		grid.append(row)

func generate_puzzle() -> void:
	var valid_puzzle_found = false
	var final_pieces = []
	var attempts = 0
	
	# Bucle que intenta generar el tablero hasta que logre exactamente 5 piezas
	while not valid_puzzle_found and attempts < 100:
		attempts += 1
		var assigned = []
		for y in range(ROWS):
			var r = []
			for x in range(COLS):
				r.append(-1)
			assigned.append(r)
			
		var current_pieces = []
		var piece_id = 0
		
		for y in range(ROWS):
			for x in range(COLS):
				if assigned[y][x] == -1:
					var current_piece_cells = []
					var to_visit = [Vector2i(x, y)]
					
					# Obligamos a buscar piezas de exactamente 5 celdas (5x5 = 25)
					var target_size = 5 
					
					while to_visit.size() > 0 and current_piece_cells.size() < target_size:
						var idx = randi() % to_visit.size()
						var cell = to_visit[idx]
						to_visit.remove_at(idx)
						
						if assigned[cell.y][cell.x] == -1:
							# Relajamos un poco la restricción a 4x4 para que fluya mejor
							var min_x = cell.x
							var max_x = cell.x
							var min_y = cell.y
							var max_y = cell.y
							
							for c in current_piece_cells:
								if c.x < min_x: min_x = c.x
								if c.x > max_x: max_x = c.x
								if c.y < min_y: min_y = c.y
								if c.y > max_y: max_y = c.y
								
							if (max_x - min_x) > 3 or (max_y - min_y) > 3:
								continue 
							
							assigned[cell.y][cell.x] = piece_id
							current_piece_cells.append(cell)
							
							var neighbors = [
								Vector2i(cell.x + 1, cell.y),
								Vector2i(cell.x - 1, cell.y),
								Vector2i(cell.x, cell.y + 1),
								Vector2i(cell.x, cell.y - 1)
							]
							for n in neighbors:
								if n.x >= 0 and n.x < COLS and n.y >= 0 and n.y < ROWS:
									if assigned[n.y][n.x] == -1:
										to_visit.append(n)
										
					current_pieces.append(current_piece_cells)
					piece_id += 1
		
		if current_pieces.size() == 5:
			final_pieces = current_pieces
			valid_puzzle_found = true
			
	current_spawn_index = 0
	for cells in final_pieces:
		var normalized_shape = normalize_shape(cells)
		spawn_piece(normalized_shape)

func normalize_shape(cells: Array) -> Array:
	var min_x = 999
	var min_y = 999
	for cell in cells:
		if cell.x < min_x: min_x = cell.x
		if cell.y < min_y: min_y = cell.y
	
	var normalized = []
	for cell in cells:
		normalized.append(Vector2i(cell.x - min_x, cell.y - min_y))
	return normalized

func spawn_piece(shape: Array) -> void:
	var piece = piece_scene.instantiate()
	piece.my_shape = shape
	
	var spawn_positions = [
		Vector2(300, 165), # 1. Arriba izq
		Vector2(300, 315), # 2. Medio izq
		Vector2(300, 465), # 3. Abajo izq 
		Vector2(460, 465), # 4. Abajo medio 
		Vector2(580, 465)  # 5. Abajo der 
	]
	
	if current_spawn_index < spawn_positions.size():
		piece.global_position = spawn_positions[current_spawn_index]
	else:
		piece.global_position = Vector2(280, 160) + (Vector2(20, 20) * current_spawn_index)
		
	add_child(piece)
	current_spawn_index += 1
	
# --- Funciones de snapping y validación ---
func pixel_to_grid(pixel_pos: Vector2) -> Vector2i:
	var local_pos = pixel_pos - global_position - board_offset
	var grid_x = floor(local_pos.x / CELL_SIZE)
	var grid_y = floor(local_pos.y / CELL_SIZE)
	return Vector2i(grid_x, grid_y)

func grid_to_pixel(grid_pos: Vector2i) -> Vector2:
	var pixel_x = (grid_pos.x * CELL_SIZE) + (CELL_SIZE / 2.0)
	var pixel_y = (grid_pos.y * CELL_SIZE) + (CELL_SIZE / 2.0)
	return global_position + board_offset + Vector2(pixel_x, pixel_y)

func can_place_piece(grid_origin: Vector2i, shape: Array) -> bool:
	for offset in shape:
		var check_pos = grid_origin + offset
		if check_pos.x < 0 or check_pos.x >= COLS or check_pos.y < 0 or check_pos.y >= ROWS:
			return false
		if grid[check_pos.y][check_pos.x] != 0:
			return false
	return true

func place_piece(grid_origin: Vector2i, shape: Array) -> void:
	for offset in shape:
		var pos = grid_origin + offset
		grid[pos.y][pos.x] = 1
	check_win_condition()

func remove_piece(grid_origin: Vector2i, shape: Array) -> void:
	for offset in shape:
		var pos = grid_origin + offset
		if pos.x >= 0 and pos.x < COLS and pos.y >= 0 and pos.y < ROWS:
			grid[pos.y][pos.x] = 0

func try_snap(pixel_pos: Vector2, shape: Array) -> Vector2:
	var grid_pos = pixel_to_grid(pixel_pos)
	if can_place_piece(grid_pos, shape):
		place_piece(grid_pos, shape)
		return grid_to_pixel(grid_pos)
	return Vector2(-1, -1)

func check_win_condition() -> void:
	for y in range(ROWS):
		for x in range(COLS):
			if grid[y][x] == 0:
				return
	
	print("El ático está ordenado!")
	get_parent().game_won.emit()
