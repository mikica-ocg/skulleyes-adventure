class_name HexGrid

const SQRT_3 = sqrt(3)

var _hexes: Array
	
func _init(width_count, height_count):
	var result = []
	
	for column_index in range(height_count):
		var row_array = []
		
		for row_index in range(width_count):
			var hex = _hex_from_even_row_coords(row_index, column_index)
			row_array.append(hex)
			
		result.append(row_array)
		
	if width_count >= 3 and height_count >= 3 and false:
		var last_row = result[height_count - 1]
		
		last_row[0] = null
		last_row[width_count - 1] = null
		
	_hexes = result
			
	pass
	
func _hex_from_even_row_coords(row: int, count: int):
	return HexBuilder.create_from_even_row_coords(row, count)
	
	
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
