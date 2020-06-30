class_name HexGridBuilder

static func create(max_width_count: int, max_height_count: int) -> HexGrid:
	if max_width_count % 2 == 0:
		max_width_count += -1
	
	if max_height_count % 2 == 0:
		max_height_count += -1
		
	assert(max_width_count > 0 and max_height_count > 0)
		
	return HexGrid.new(max_width_count, max_height_count)
