class_name HexGrid

const SQRT_3 = sqrt(3)

var _hexes: Array
	
func _init(width_count, height_count):
	var result = []
	
	for row_index in range(height_count):
		var row_array = []
		
		for column_index in range(width_count):
			var hex = _hex_from_even_row_coords(row_index, column_index)
			row_array.append(hex)
			
		result.append(row_array)
		
	if width_count >= 3 and height_count >= 3:
		var last_row = result[height_count - 1]
		
		for index in range(width_count):
			if index % 2 == 0:
				last_row[index] = null
		
	_hexes = result
			
	pass
	
	
func _hex_from_even_row_coords(row: int, count: int):
	return HexBuilder.create_from_even_row_coords(row, count)
	
	
func normalized_size() -> Vector2:
	if _hexes == null or _hexes.size() == 0:
		return Vector2()
	
	var height = _hexes.size() * SQRT_3
	var width = 1.5 * _hexes[0].size() + 0.5
	
	return Vector2(width, height)
	
	
func hex_from_normalized_pos(pos: Vector2) -> Hex:
	var q = 2.0/3.0 * (pos.x - 1)
	var r = pos.y / SQRT_3 - q / 2.0 - 1
	
	var cube_raw = Hex.axial_to_cube_coords(q, r)
	var cube = Hex.round_cube_coords(cube_raw)
	var even_row = Hex.cube_to_even_row_coords(cube)
	
	var row = int(even_row.y)
	var col = int(even_row.x)
	
	return hex_from_row_and_col(row, col)
	
	
func hex_from_row_and_col(row: int, col: int) -> Hex:
	if col < 0 or row < 0 or row >= _hexes.size() or col >= _hexes[row].size():
		return null
	
	return _hexes[row][col]
	
	
func line_from_normalized(first_pos: Vector2, second_pos: Vector2) -> Array:
	var result = []
	
	var previous = null
	
	for point in _points_for_line_calculation(first_pos, second_pos):
		var current = hex_from_normalized_pos(point)
		
		if previous != current:
			result.append(current)
			previous = current
	
	return result
	
	
func _points_for_line_calculation(first: Vector2, second: Vector2) -> Array:
	var h1 = hex_from_normalized_pos(first)
	var h2 = hex_from_normalized_pos(second)
	
	if h1 == null or h2 == null:
		return []
		
	var precision_factor = 1.5
		
	var count = h1.distance_to(h2) + 1
	count *= precision_factor
	
	var delta = (second - first) / count
	var result = []
	
	for index in range(count + 1):
		result.append(first + delta * index)
		
	return result
	
	
### ITERATOR ###
	
var iterator: GridIterator = null

func _iter_init(_arg) -> bool:
	iterator = GridIterator.new(_hexes)
	return iterator._iter_init(_arg)
	
func _iter_next(_arg) -> bool:
	return iterator._iter_next(_arg)
	
func _iter_get(_arg) -> Hex:
	return iterator._iter_get(_arg)

class GridIterator:
	var _hexes: Array
	
	var row: int = 0
	var column: int = 0
	
	func _init(hexes):
		self._hexes = hexes
		
	func _iter_init(_arg) -> bool:
		row = -1
		column = 0
		
		return column < _hexes.size() and _find_next_hex() != null
	
	func _iter_next(_arg) -> bool:
		return _find_next_hex() != null
		
	func _iter_get(_arg) -> Hex:
		return _hexes[column][row]
		
	func _find_next_hex() -> Hex:
		var next_hex = null
		
		while(next_hex == null):
			row += 1
		
			if _hexes[column].size() <= row:
				row = 0
				column += 1
				
			if _hexes.size() <= column:
				break
			
			next_hex = _hexes[column][row]
			
		return next_hex
