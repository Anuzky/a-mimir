extends Area2D

const CELL_SIZE = 50
var is_dragging = false
var is_snapped = false
var offset_from_mouse = Vector2.ZERO
var start_position = Vector2.ZERO
var my_shape = [] 

var box_texture = preload("res://minigames/ubongo/cajita.svg")

func _ready() -> void:
	start_position = global_position
	build_visuals_and_collisions()

	scale = Vector2(0.7, 0.7)

func build_visuals_and_collisions() -> void:
	for child in get_children():
		child.queue_free()
		
	for cell in my_shape:
		var cell_pos = Vector2(cell.x * CELL_SIZE, cell.y * CELL_SIZE)
		
		var sprite = Sprite2D.new()
		sprite.texture = box_texture
		sprite.position = cell_pos
		
		sprite.scale = Vector2(0.45, 0.45)  
		add_child(sprite)
		
		var col = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = Vector2(CELL_SIZE - 2, CELL_SIZE - 2)
		col.shape = shape
		col.position = cell_pos
		add_child(col)

func _process(_delta: float) -> void:
	if is_dragging:
		global_position = get_global_mouse_position() + offset_from_mouse

func _on_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			z_index = 10 
			
			# Efecto pop al levantar la pieza
			var tween = create_tween()
			tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_BOUNCE)
			
			offset_from_mouse = global_position - get_global_mouse_position()
			
			# Si estaba en la grilla, la desvinculamos de la matriz matemática
			if is_snapped:
				var board = get_parent()
				if board.has_method("remove_piece"):
					var grid_pos = board.pixel_to_grid(global_position)
					board.remove_piece(grid_pos, my_shape)
				is_snapped = false
				
func _input(event: InputEvent) -> void:
	if is_dragging and event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if not event.pressed:
			is_dragging = false
			z_index = 0  
			_snap_to_grid()

func _snap_to_grid() -> void:
	var board = get_parent()
	if board.has_method("try_snap"):
		var snap_position = board.try_snap(global_position, my_shape)
		var tween = create_tween()
		
		if snap_position != Vector2(-1, -1):
			is_snapped = true
			tween.tween_property(self, "global_position", snap_position, 0.15).set_trans(Tween.TRANS_SINE)
			tween.parallel().tween_property(self, "scale", Vector2(1.0, 1.0), 0.15)
		else:
			tween.tween_property(self, "global_position", start_position, 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tween.parallel().tween_property(self, "scale", Vector2(0.7, 0.7), 0.25)
