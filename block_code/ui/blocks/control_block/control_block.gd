class_name ControlBlock
extends Block

const Constants = preload("res://block_code/ui/constants.gd")


func _ready():
	super()

	%TopBackground.color = color
	%TopBackground.shift_bottom = Constants.CONTROL_MARGIN
	%BottomBackground.color = color
	%BottomBackground.shift_top = Constants.CONTROL_MARGIN
	%SnapPoint.add_theme_constant_override("margin_left", Constants.CONTROL_MARGIN)
	%SnapGutter.color = color
	%SnapGutter.custom_minimum_size.x = Constants.CONTROL_MARGIN


func _on_drag_drop_area_drag_started(offset: Vector2) -> void:
	_drag_started(offset)


static func get_block_class():
	return "ControlBlock"


static func get_scene_path():
	return "res://block_code/ui/blocks/control_block/control_block.tscn"
