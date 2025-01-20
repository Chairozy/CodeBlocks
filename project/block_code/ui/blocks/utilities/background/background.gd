extends Control

const BlockTreeUtil = preload("res://block_code/ui/block_tree_util.gd")
const Constants = preload("res://block_code/ui/constants.gd")

var outline_color: Color
var parent_block: Block

@export var color: Color:
	set = _set_color

@export var show_top: bool = true:
	set = _set_show_top

## Horizontally shift the top knob
@export var shift_top: float = 0.0:
	set = _set_shift_top

## Horizontally shift the bottom knob
@export var shift_bottom: float = 0.0:
	set = _set_shift_bottom


func _set_color(new_color):
	color = new_color
	outline_color = color.darkened(0.2)
	queue_redraw()


func _set_show_top(new_show_top):
	show_top = new_show_top
	queue_redraw()


func _set_shift_top(new_shift_top):
	shift_top = new_shift_top
	queue_redraw()


func _set_shift_bottom(new_shift_bottom):
	shift_bottom = new_shift_bottom
	queue_redraw()


func _ready():
	parent_block = BlockTreeUtil.get_parent_block(self)
	parent_block.focus_entered.connect(queue_redraw)
	parent_block.focus_exited.connect(queue_redraw)


func round_corner(polygon: PackedVector2Array, point: Vector2, side: String):
	if side == "br":
		polygon.append(Vector2(point.x, point.y - 10.0))
		polygon.append(Vector2(point.x - 1.0, point.y - 4.0))
		polygon.append(Vector2(point.x - 2.0, point.y - 3.0))
		polygon.append(Vector2(point.x - 3.0, point.y - 2.0))
		polygon.append(Vector2(point.x - 4.0, point.y - 1.0))
		polygon.append(Vector2(point.x - 10.0, point.y))
	elif side == "tr":
		polygon.append(Vector2(point.x - 10.0, point.y))
		polygon.append(Vector2(point.x - 4.0, point.y + 1.0))
		polygon.append(Vector2(point.x - 3.0, point.y + 2.0))
		polygon.append(Vector2(point.x - 2.0, point.y + 3.0))
		polygon.append(Vector2(point.x - 1.0, point.y + 4.0))
		polygon.append(Vector2(point.x, point.y + 10.0))
	elif side == "bl":
		polygon.append(Vector2(point.x + 10.0, point.y))
		polygon.append(Vector2(point.x + 4.0, point.y - 1.0))
		polygon.append(Vector2(point.x + 3.0, point.y - 2.0))
		polygon.append(Vector2(point.x + 2.0, point.y - 3.0))
		polygon.append(Vector2(point.x + 1.0, point.y - 4.0))
		polygon.append(Vector2(point.x, point.y - 10.0))
	elif side == "tl":
		polygon.append(Vector2(point.x, point.y + 10.0))
		polygon.append(Vector2(point.x + 1.0, point.y + 4.0))
		polygon.append(Vector2(point.x + 2.0, point.y + 3.0))
		polygon.append(Vector2(point.x + 3.0, point.y + 2.0))
		polygon.append(Vector2(point.x + 4.0, point.y + 1.0))
		polygon.append(Vector2(point.x + 10.0, point.y))

func _draw():
	var fill_polygon: PackedVector2Array
	fill_polygon.append(Vector2(0.0, 0.0))
	if show_top:
		fill_polygon.append(Vector2(Constants.KNOB_X + shift_top, 0.0))
		fill_polygon.append(Vector2(Constants.KNOB_X + Constants.KNOB_Z + shift_top, Constants.KNOB_H))
		fill_polygon.append(Vector2(Constants.KNOB_X + Constants.KNOB_Z + Constants.KNOB_W + shift_top, Constants.KNOB_H))
		fill_polygon.append(Vector2(Constants.KNOB_X + Constants.KNOB_Z * 2 + Constants.KNOB_W + shift_top, 0.0))

	round_corner(fill_polygon, Vector2(size.x, 0.0), "tr")
	round_corner(fill_polygon, Vector2(size.x, size.y), "br")

	fill_polygon.append(Vector2(Constants.KNOB_X + Constants.KNOB_Z * 2 + Constants.KNOB_W + shift_bottom, size.y))
	fill_polygon.append(Vector2(Constants.KNOB_X + Constants.KNOB_Z + Constants.KNOB_W + shift_bottom, size.y + Constants.KNOB_H))
	fill_polygon.append(Vector2(Constants.KNOB_X + Constants.KNOB_Z + shift_bottom, size.y + Constants.KNOB_H))
	fill_polygon.append(Vector2(Constants.KNOB_X + shift_bottom, size.y))
	fill_polygon.append(Vector2(0.0, size.y))
	fill_polygon.append(Vector2(0.0, 0.0))
	#round_corner(fill_polygon, Vector2(0.0, size.y), "bl")
	#round_corner(fill_polygon, Vector2(0.0, 0.0), "tl")

	var stroke_polygon: PackedVector2Array
	var edge_polygon: PackedVector2Array
	var outline_middle = Constants.OUTLINE_WIDTH / 2

	if shift_top > 0:
		stroke_polygon.append(Vector2(shift_top - outline_middle, 0.0))
	else:
		stroke_polygon.append(Vector2(shift_top, 0.0))

	if show_top:
		stroke_polygon.append(Vector2(Constants.KNOB_X + shift_top, 0.0))
		stroke_polygon.append(Vector2(Constants.KNOB_X + Constants.KNOB_Z + shift_top, Constants.KNOB_H))
		stroke_polygon.append(Vector2(Constants.KNOB_X + Constants.KNOB_Z + Constants.KNOB_W + shift_top, Constants.KNOB_H))
		stroke_polygon.append(Vector2(Constants.KNOB_X + Constants.KNOB_Z * 2 + Constants.KNOB_W + shift_top, 0.0))

	round_corner(stroke_polygon, Vector2(size.x, 0.0), "tr")
	round_corner(stroke_polygon, Vector2(size.x, size.y), "br")

	stroke_polygon.append(Vector2(Constants.KNOB_X + Constants.KNOB_Z * 2 + Constants.KNOB_W + shift_bottom, size.y))
	stroke_polygon.append(Vector2(Constants.KNOB_X + Constants.KNOB_Z + Constants.KNOB_W + shift_bottom, size.y + Constants.KNOB_H))
	stroke_polygon.append(Vector2(Constants.KNOB_X + Constants.KNOB_Z + shift_bottom, size.y + Constants.KNOB_H))
	stroke_polygon.append(Vector2(Constants.KNOB_X + shift_bottom, size.y))

	if shift_bottom > 0:
		stroke_polygon.append(Vector2(shift_bottom - outline_middle, size.y))
	else:
		stroke_polygon.append(Vector2(shift_bottom, size.y))

	if shift_top > 0:
		edge_polygon.append(Vector2(0.0, 0.0))
	else:
		edge_polygon.append(Vector2(0.0, 0.0 - outline_middle))

	if shift_bottom > 0:
		edge_polygon.append(Vector2(0.0, size.y))
	else:
		edge_polygon.append(Vector2(0.0, size.y + outline_middle))

	draw_colored_polygon(fill_polygon, color)
	draw_polyline(stroke_polygon, Constants.FOCUS_BORDER_COLOR if parent_block.has_focus() else outline_color, Constants.OUTLINE_WIDTH)
	draw_polyline(edge_polygon, Constants.FOCUS_BORDER_COLOR if parent_block.has_focus() else outline_color, Constants.OUTLINE_WIDTH)
