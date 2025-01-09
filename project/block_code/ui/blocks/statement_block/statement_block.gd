class_name StatementBlock
extends Block

const Types = preload("res://block_code/types/types.gd")

@onready var _background := %Background

var arg_name_to_param_input_dict: Dictionary
var args_to_add_after_format: Dictionary  # Only used when loading


func _ready():
	super()

	if definition != null and definition.type != Types.BlockType.STATEMENT:
		_background.show_top = false
	_background.color = color


func _on_drag_drop_area_drag_started(offset: Vector2) -> void:
	_drag_started(offset)


static func get_block_class():
	return "StatementBlock"


static func get_scene_path():
	return "res://block_code/ui/blocks/statement_block/statement_block.tscn"