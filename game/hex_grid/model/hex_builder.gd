class_name HexBuilder

static func create_from_even_row_coords(row: int, column: int) -> Hex:
	return Hex.new(Hex.even_row_to_cube_coords(row, column))
