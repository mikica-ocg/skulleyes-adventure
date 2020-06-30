extends Node2D
class_name HexVisualizer

const SQRT3: float = sqrt(3)

export(int) var half_width = 24

export(int) var max_width_count = 7
export(int) var max_height_count = 7

var selected: bool = false

onready var grid = HexGridBuilder.create(max_width_count, max_height_count)

func _draw():
	for hex in grid:
		draw_hex(hex, half_width, selected)
	
	
	
func draw_hex(hex: Hex, half_width: int, selected: bool):
	var dw = half_width
	var dh = SQRT3 * half_width
	
	var cube_coords = hex.get_cube_coords()
	var size = half_width + half_width
	
	var pos_offset = hex.get_normalized_2d_pos() * size
	
	var offsets = [
		Vector2(-dw, -dh) + pos_offset,
		Vector2(dw, -dh) + pos_offset,
		Vector2(2 * dw, 0) + pos_offset,
		Vector2(dw, dh) + pos_offset,
		Vector2(-dw, dh) + pos_offset,
		Vector2(-2 * dw, 0) + pos_offset
	]
	
	if selected:
#		draw_polygon(offsets, [Color.green])
		draw_polygon(offsets, [Color(72.0/255, 106.0/255, 71.0/255, 0.5)])
	
	draw_edges(position, offsets, Color.hotpink)
	draw_center(Color.hotpink)
	draw_corners(offsets, Color.palegreen)


func draw_edges(pos: Vector2, offsets: Array, color: Color):
	for index in range(0, offsets.size() - 1):
		draw_line(offsets[index], offsets[index + 1], color)
		
	draw_line(offsets[offsets.size() - 1], offsets[0], color)
	pass
	
	
func draw_center(color: Color):
	draw_circle(Vector2(0, 0), 2, color)
	
	pass
	
	
func draw_corners(offsets: Array, color: Color):
	for point in offsets:
		draw_circle(point, 2, color)
