extends Node2D
class_name CanvasScene

static var _instance: CanvasScene

static func get_instance() -> CanvasScene:
	return _instance

func _enter_tree() -> void:
	_instance = self

func _ready():
	Callable(func ():
		var cam = get_parent().get_node("Camera2D")
		var tilemap = get_child(0)
		var rect = tilemap.get_used_rect() as Rect2
		rect.position = tilemap.map_to_local(rect.position)
		rect.size.y -= 2
		rect.size = tilemap.map_to_local(rect.size)
		cam.position = rect.size / 2
		).call_deferred()

func create_preview() -> Node2D:
	var preview_scene := PreviewScene.new()
	preview_scene.name = &"PreviewScene"
	var tilemap = get_children()[0].duplicate() as TileMap
	preview_scene.add_child(tilemap)

	return preview_scene

