extends Node2D
class_name HexVisualizer

const SQRT3: float = sqrt(3)

export(int) var half_width = 24

export(int) var max_width_count = 7
export(int) var max_height_count = 7

export(NodePath) var debug_label_path
onready var debug_label = get_node(debug_label_path) as Label

var los_origin = null
var selected: Hex = null

onready var grid = HexGridBuilder.create(max_width_count, max_height_count)
onready var debug_font = _create_debug_font()

func _input(event):
	if event is InputEventMouseButton:
		select_los_origin(get_local_mouse_position())
#		print("Mouse click at " + str(event.position))
		update()
	elif event is InputEventMouseMotion:
		var local_mouse_pos = get_local_mouse_position()
		var hex = grid.hex_from_normalized_pos(local_mouse_pos / (2 * half_width))
		
		if hex != selected:
			selected = hex
			update()
		
#		debug_label.text = "Mouse pos: " + str(local_mouse_pos)
		
		pass
	pass


func select_los_origin(pos: Vector2):
	var size = half_width + half_width
	var n_pos = pos / size
	
	var hex = grid.hex_from_normalized_pos(pos / size)
	
	if hex != null:
		var found_corner = null
		
		for corner in hex.get_normalized_2d_corners():
			var x_is_in_bounds = n_pos.x > corner.x - 0.25 and n_pos.x < corner.x + 0.25
			var y_is_in_bounds = n_pos.y > corner.y - 0.25 and n_pos.y < corner.y + 0.25
			
			if x_is_in_bounds and y_is_in_bounds:
				found_corner = corner
				break
		
		if found_corner != null:
			los_origin = found_corner * size
		else:
			los_origin = hex.get_normalized_2d_pos() * size
		
	else:
		los_origin = null
	
	pass


func _draw():
	for hex in grid:
		draw_hex(hex, half_width, false)
		
	if selected != null:
		draw_hex(selected, half_width, true)
		
	if los_origin != null and selected != null:
		draw_los(los_origin, selected)
	
	draw_container()
	
	
func draw_hex(hex: Hex, half_width: int, selected: bool):
	var size = half_width + half_width
	
	var offsets = hex.get_multiplied_2d_corners(size)
	var pos_offset = hex.get_normalized_2d_pos() * size
	
	if selected:
		draw_polygon(offsets, [Color(72.0/255, 106.0/255, 71.0/255, 0.5)])
	
	draw_edges(position, offsets, Color.hotpink)
#	draw_center(Color.hotpink)
	draw_corners(offsets, Color.palegreen)
	
	_draw_debug_string(pos_offset, hex.debug_str)


func draw_edges(_pos: Vector2, offsets: Array, color: Color):
	for index in range(0, offsets.size() - 1):
		draw_line(offsets[index], offsets[index + 1], color)
		
	draw_line(offsets[offsets.size() - 1], offsets[0], color)


func draw_corners(offsets: Array, color: Color):
	for point in offsets:
		draw_circle(point, 2, color)


func draw_los(origin: Vector2, selected: Hex):
	var size = half_width + half_width
	draw_line(origin, selected.get_normalized_2d_pos() * size, Color.blueviolet)
	
	var los_hexes = grid.line_from_normalized(origin / size, selected.get_normalized_2d_pos())
	
	debug_label.text = "LOS count = " + str(los_hexes.size())
	
	for hex in los_hexes:
		draw_center((hex as Hex).get_normalized_2d_pos() * size, Color.aliceblue, 8)
		
	for point in grid._points_for_line_calculation(origin / size, selected.get_normalized_2d_pos()):
		draw_center(point * size, Color.red, 4)


func draw_center(position: Vector2, color: Color, radius: float):
	draw_circle(position, radius, color)


func draw_container():
	var normalized = grid.normalized_size()
	var width = 2 * half_width * normalized.x
	var height = 2 * half_width * normalized.y
	
	var points = [
		Vector2(0, 0),
		Vector2(width, 0),
		Vector2(width, height),
		Vector2(0, height),
		Vector2(0, 0)
	]
	
	for index in range(points.size() - 1):
		draw_line(points[index], points[index + 1], Color.aqua)


func _create_debug_font() -> DynamicFont:
	var font = DynamicFont.new()
	
	font.font_data = load("res://fonts/FantasqueSansMono-Regular.ttf")
	font.size = 16
	
	return font
	
	
func _draw_debug_string(pos: Vector2, text: String):
	pos += -debug_font.get_string_size(text) / 2
	pos.y += debug_font.get_ascent()
	
	draw_string(debug_font, pos, text)

