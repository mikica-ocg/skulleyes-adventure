class_name HexBuilder

static func create_from_even_row_coords(row: int, column: int) -> Hex:
	var hex = Hex.new(Hex.even_row_to_cube_coords(row, column))
	hex.debug_str = 'c:' + str(column) + '/r:' + str(row)
	return hex
