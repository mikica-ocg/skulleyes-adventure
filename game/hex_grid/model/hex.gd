class_name Hex

var _coords: Vector3

var debug_str: String = ''

const SQRT3 = sqrt(3)

enum Direction { N, NE, SE, S, SW, NW }

func _init(cube_coords):
	_coords = cube_coords


func get_cube_coords():
	return Vector3(_coords.x, _coords.y, _coords.z)


func get_even_row_coords():
	return cube_to_even_row_coords(_coords)


func get_normalized_2d_pos():
	var x = 1.5 * _coords.x + 1 # offset to center
	var y = SQRT3 * (_coords.x / 2 + _coords.z + 1) # offset to center
	
	return Vector2(x, y)


func get_normalized_2d_corners() -> Array:
	return get_multiplied_2d_corners(1)


func get_multiplied_2d_corners(size: float) -> Array:
	var width_extent = 0.5 * size
	var height_extent = SQRT3 / 2.0 * size
	
	var pos_offset = get_normalized_2d_pos() * size
	
	return [
		Vector2(-width_extent, -height_extent) + pos_offset,
		Vector2(width_extent, -height_extent) + pos_offset,
		Vector2(2 * width_extent, 0) + pos_offset,
		Vector2(width_extent, height_extent) + pos_offset,
		Vector2(-width_extent, height_extent) + pos_offset,
		Vector2(-2 * width_extent, 0) + pos_offset
	]


func get_adjacent_cube_coords(direction) -> Vector3:
	return _coords + adjacent_offsets[direction]


func get_adjacent_hex_offset(direction):
	return adjacent_offsets[direction]


func distance_to(hex: Hex) -> int:
	var dist = (_coords - hex._coords) / 2
	return int(abs(dist.x) + abs(dist.y) + abs(dist.z))


const adjacent_offsets = [
	Vector3(0, +1, -1),
	Vector3(+1, 0, -1),
	Vector3(+1, -1, 0),
	Vector3(0, -1, +1),
	Vector3(-1, 0, +1),
	Vector3(-1, +1, 0)
]


static func axial_to_cube_coords(q: float, r: float) -> Vector3:
	return Vector3(q, -q - r, r)


static func cube_to_even_row_coords(coords: Vector3) -> Vector2:
	var col = coords.x
	var row = coords.z + (coords.x + (int(coords.x) & 1)) / 2
	
	return Vector2(col, row)


static func even_row_to_cube_coords(row: int, col: int):
	var x = col
	var z = row - (col + (int(col) & 1)) / 2
	var y = -x - z
	
	return Vector3(x, y, z)


static func round_cube_coords(cube: Vector3) -> Vector3:
	var rx = round(cube.x)
	var ry = round(cube.y)
	var rz = round(cube.z)
	
	var x_diff = abs(rx - cube.x)
	var y_diff = abs(ry - cube.y)
	var z_diff = abs(rz - cube.z)
	
	if x_diff > y_diff and x_diff > z_diff:
		rx = -ry - rz
	elif y_diff > z_diff:
		ry = -rx - rz
	else:
		rz = -rx - ry
		
	return Vector3(rx, ry, rz)
