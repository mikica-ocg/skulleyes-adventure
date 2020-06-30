class_name Hex

var _coords: Vector3
const SQRT3 = sqrt(3)

enum Direction { N, NE, SE, S, SW, NW }

func _init(cube_coords):
	_coords = cube_coords

func get_cube_coords():
	return Vector3(_coords.x, _coords.y, _coords.z)
	
func get_even_row_coords():
	return cube_to_even_row_coords(_coords)
	
func get_normalized_2d_pos():
	var x = 1.5 * _coords.x
	var y = SQRT3 * (_coords.x / 2 + _coords.z)
	
	return Vector2(x, y)
	
func get_adjacent_hex(direction):
	return _coords + adjacent_offsets[direction]
	
func get_adjacent_hex_offset(direction):
	return adjacent_offsets[direction]
	
func distance_to(hex: Hex) -> int:
	var dist = (_coords - hex._coords) / 2
	return int(abs(_coords.x) + abs(_coords.y) + abs(_coords.z))

const adjacent_offsets = [
	Vector3(0, +1, -1),
	Vector3(+1, 0, -1),
	Vector3(+1, -1, 0),
	Vector3(0, -1, +1),
	Vector3(-1, 0, +1),
	Vector3(-1, +1, 0)
]

static func cube_to_even_row_coords(coords: Vector3) -> Vector2:
	var col = coords.x
	var row = coords.z + (coords.x + (int(coords.x) & 1)) / 2
	
	return Vector2(row, col)

static func even_row_to_cube_coords(row: int, col: int):
	var x = col
	var z = row - (col + (int(col) & 1)) / 2
	var y = -x - z
	
	return Vector3(x, y, z)

