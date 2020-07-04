extends Node2D


var col: int = 0
var row: int = 0

var selected: Hex = null

onready var visualizer = $".."


func _process(delta):
	var old_col = col
	var old_row = row
	
	if Input.is_action_just_released("ui_left"):
		col += -1
	if Input.is_action_just_released("ui_right"):
		col += 1
	if Input.is_action_just_released("ui_up"):
		row += -1
	if Input.is_action_just_released("ui_down"):
		row += 1
		
		
	var grid = visualizer.grid as HexGrid
	
	var s = grid.hex_from_row_and_col(row, col)
	
	if s == null:
		col = old_col
		row = old_row
		
		return
	
	if s != selected:
		selected = s
		
		$Indicator.visible = selected != null
		
		if selected != null:
			$Indicator.position = selected.get_normalized_2d_pos() * visualizer.half_width * 2.0
			$Label.text = str(selected.get_multiplied_2d_corners(visualizer.half_width * 2)) #str($Indicator.position)
	
	
	pass



