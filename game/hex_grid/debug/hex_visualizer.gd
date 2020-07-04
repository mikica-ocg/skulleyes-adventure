extends Node2D
class_name HexVisualizer

const SQRT3: float = sqrt(3)

export(int) var half_width = 24

export(int) var max_width_count = 7
export(int) var max_height_count = 7

export(NodePath) var debug_label_path
onready var debug_label = get_node(debug_label_path) as Label

var selected: Hex = null

onready var grid = HexGridBuilder.create(max_width_count, max_height_count)
onready var debug_font = _create_debug_font()

func _input(event):
	if event is InputEventMouseButton:
		print("Mouse click at " + str(event.position))
	elif event is InputEventMouseMotion:
		var local_mouse_pos = get_local_mouse_position()
		var hex = grid.hex_from_normalized_pos(local_mouse_pos / (2 * half_width))
		
		if hex != selected:
			selected = hex
			update()
		
		debug_label.text = "Mouse pos: " + str(local_mouse_pos)
		
		pass
	pass
	

func _draw():
	for hex in grid:
		draw_hex(hex, half_width, false)
		
	if selected != null:
		draw_hex(selected, half_width, true)
	
	draw_container()
	
	
func draw_hex(hex: Hex, half_width: int, selected: bool):
	var dw = half_width
	var dh = SQRT3 * half_width
	
	var size = half_width + half_width
	
	var offsets = hex.get_multiplied_2d_edges(size)
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
	
	
func draw_center(color: Color):
	draw_circle(Vector2(0, 0), 2, color)
	
	
func draw_corners(offsets: Array, color: Color):
	for point in offsets:
		draw_circle(point, 2, color)


func draw_container():
	var normalized = grid.normalized_size()
	var width = 4 * half_width * normalized.x
	var height = SQRT3 * 2 * half_width * normalized.y
	
	var points = [
		Vector2(0, 0),
		Vector2(width, 0),
		Vector2(width, height),
		Vector2(0, height),
		Vector2(0, 0)
	]
	
	for index in range(points.size() - 1):
		draw_line(points[index], points[index + 1], Color.aqua)
	
	print("normalized=" + str(normalized))


func _create_debug_font() -> DynamicFont:
	var font = DynamicFont.new()
	
	font.font_data = load("res://fonts/FantasqueSansMono-Regular.ttf")
	font.size = 16
	
	return font
	
	
func _draw_debug_string(pos: Vector2, text: String):
	pos += -debug_font.get_string_size(text) / 2
	pos.y += debug_font.get_ascent()
	
#	pos.x += 
#	pos.y += debug_font.get_ascent()
	
	draw_string(debug_font, pos, text)
