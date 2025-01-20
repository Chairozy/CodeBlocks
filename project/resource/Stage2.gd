extends CanvasScene

var current_level_name: String = ""
@export var camera2d : Camera2D
@onready var hero := $Hero

func _ready():
	_next_level("1")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _next_level(next: String, pos: Vector2 = Vector2.ZERO):
	if current_level_name != "":
		await create_tween().tween_property(camera2d, "global_position", camera2d.global_position + (pos - hero.global_position), 1.0).set_trans(Tween.TRANS_EXPO).finished
		get_node(current_level_name).hide()
		BlockCodeManager.main_panel.get_node("%RunNode").button_pressed = false
		for tree in  hero.get_node("BlockCode").block_script.block_serialization_trees:
			tree.root.children.clear()
		BlockCodeManager.main_panel.get_node("%BlockCanvas")._on_context_changed()
		BlockCodeManager.main_panel.save_script()
		hero.global_position = pos
	
	if next == "finish":
		return
	else:
		current_level_name = "Level" + next
		get_node(current_level_name).show()
