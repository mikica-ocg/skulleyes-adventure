class_name HexGrid

const SQRT_3 = sqrt(3)
const EPSILON = 0.00001

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
	var cube_raw = _to_raw_cube_coords(pos)
	var cube = Hex.round_cube_coords(cube_raw)
	var even_row = Hex.cube_to_even_row_coords(cube)
	
	var row = int(even_row.y)
	var col = int(even_row.x)
	
	return hex_from_row_and_col(row, col)
	
	
func _to_raw_cube_coords(pos: Vector2) -> Vector3:
	var q = 2.0/3.0 * (pos.x - 1)
	var r = pos.y / SQRT_3 - q / 2.0 - 1
	return Hex.axial_to_cube_coords(q, r)
	
	
func hex_from_row_and_col(row: int, col: int) -> Hex:
	if col < 0 or row < 0 or row >= _hexes.size() or col >= _hexes[row].size():
		return null
	
	return _hexes[row][col]
	
	
func intersecting_edges_from_normalized(first_pos: Vector2, second_pos: Vector2) -> Array:
	var result = []
	
	var line = line_from_normalized(first_pos, second_pos)
	
	var first_hex = hex_from_normalized_pos(first_pos)
	
	if first_hex != null:
		line.push_front(first_hex)
	
	for elem in line:
		var hex = elem as Hex
		
		var corners = hex.get_normalized_2d_corners()
		corners.append(corners[0])
		
		for index in range(corners.size() - 1):
			var start_point = corners[index]
			var end_point = corners[index + 1]
			
			if _are_intersecting(first_pos, second_pos, start_point, end_point):
				result.append(start_point)
				result.append(end_point)
	
	return result
	
	
func _are_intersecting(line_1_a: Vector2, line_1_b: Vector2, line_2_c: Vector2, line_2_d: Vector2) -> bool:
	return EdgeIntersectionDetector.are_intersecting(
		line_1_a, line_1_b, line_2_c, line_2_d)
	
	
func intersecting_corners_from_normalized(first_pos: Vector2, second_pos: Vector2) -> Array:
	var result = []
	
	var line = line_from_normalized(first_pos, second_pos)
	
	var first_hex = hex_from_normalized_pos(first_pos)
	
	if first_hex != null:
		line.push_front(first_hex)
	
	var epsilon_vector = Vector2(EPSILON, EPSILON)
	
	for elem in line:
		var hex = elem as Hex
		
		var corners = hex.get_normalized_2d_corners()
		
		for corner in corners:
			if _is_point_on_segment(first_pos, second_pos, corner):
				if not _is_corner_already_added(result, corner):
					result.append(corner)
		
	return result
	
func _is_point_on_segment(seg_start: Vector2, seg_end: Vector2, point: Vector2) -> bool:
	var first = seg_end - seg_start
	var second = point - seg_start

	var cp = first.cross(second)
	
	if cp > EPSILON or cp < -EPSILON:
		return false
	
	var dp = first.dot(second)

	if dp < -EPSILON:
		return false

	return dp < (seg_end - seg_start).length_squared()
	
	
func _is_corner_already_added(corners: Array, corner: Vector2) -> bool:
	for c in corners:
		var matched_x = corner.x <= c.x + EPSILON and corner.x >= c.x - EPSILON
		var matched_y = corner.y <= c.y + EPSILON and corner.y >= c.y - EPSILON
		
		if matched_x and matched_y:
			return true
	
	return false
	
func line_from_normalized(first_pos: Vector2, second_pos: Vector2) -> Array:
	return line_from_normalized_with_origin_hex(
		hex_from_normalized_pos(first_pos), 
		first_pos, 
		second_pos
	)
	
	
func line_from_normalized_with_origin_hex(origin: Hex, first_pos: Vector2, second_pos: Vector2) -> Array:
	var result = []
	
	var previous = null
	var current_distance = 0
	
	if origin == null:
		return []
	
	for point in _points_for_line_calculation(first_pos, second_pos):
		var current = hex_from_normalized_pos(point)
		
		if previous != current and current != null and current.distance_to(origin) > current_distance:
			result.append(current)
			previous = current
			current_distance += 1
	
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
	
	
class EdgeIntersectionDetector:
	
	enum ORIENTATION {
		colinear,
		clockwise,
		counterclockwise
	}
	
	static func are_intersecting(
		line_1_a: Vector2, line_1_b: Vector2, 
		line_2_c: Vector2, line_2_d: Vector2) -> bool:
		
		var o1 = _orientation(line_1_a, line_1_b, line_2_c)
		var o2 = _orientation(line_1_a, line_1_b, line_2_d)
		var o3 = _orientation(line_2_c, line_2_d, line_1_a)
		var o4 = _orientation(line_2_c, line_2_d, line_1_b)
		
		if o1 != o2 and o3 != o4:
			return true
			
		if o1 == ORIENTATION.colinear and _colinear_on_segment(line_1_a, line_1_b, line_2_c):
			return true
			
		if o2 == ORIENTATION.colinear and _colinear_on_segment(line_1_a, line_1_b, line_2_d):
			return true
			
		if o3 == ORIENTATION.colinear and _colinear_on_segment(line_2_c, line_2_d, line_1_a):
			return true
			
		if o4 == ORIENTATION.colinear and _colinear_on_segment(line_2_c, line_2_d, line_1_b):
			return true
		
		return false
		
	static func _orientation(p: Vector2, q: Vector2, r: Vector2) -> int:
		var val = ((q.y - p.y) * (r.x - q.x)) - ((q.x - p.x) * (r.y - q.y))
		
		if val > EPSILON:
			return ORIENTATION.clockwise
		if val < -EPSILON:
			return ORIENTATION.counterclockwise
		
		return ORIENTATION.colinear
	
	static func _colinear_on_segment(start: Vector2, end: Vector2, point: Vector2) -> bool:
		var x_is_in = point.x <= max(start.x, end.x) and point.x >= min(start.x, end.x)
		var y_is_in = point.y <= max(start.y, end.y) and point.y >= min(start.y, end.y)
		
		return x_is_in and y_is_in
	
	
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
