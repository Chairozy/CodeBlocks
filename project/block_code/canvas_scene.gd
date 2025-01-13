extends Node2D
class_name CanvasScene

static var _instance: CanvasScene

static func get_instance() -> CanvasScene:
	return _instance

func _enter_tree() -> void:
	_instance = self

func create_preview() -> Node2D:
	var preview_scene := PreviewScene.new()
	preview_scene.name = &"PreviewScene"
	var scene_root := duplicate()

	for child in scene_root.get_children():
		if child.visible:
			child.reparent(preview_scene)

	return preview_scene

