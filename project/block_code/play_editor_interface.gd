class_name PlayEditorInterface

static var _inpector: PlayEditorInspector

static func get_inspector() -> PlayEditorInspector:
	if _inpector == null:
		_inpector = PlayEditorInspector.new()
	return _inpector

static func get_edited_scene_root() -> Node:
	return BlockCodeManager.selected_block_code
