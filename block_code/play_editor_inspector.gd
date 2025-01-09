class_name PlayEditorInspector

var _edit_object: BlockCode
signal edited_object_changed
signal property_edited

func add_custom_control(container: Container) -> void:
	pass

func set_edited_object(edit_object: BlockCode) -> void:
	_edit_object = edit_object
	edited_object_changed.emit()

func get_edited_object():
	return _edit_object
