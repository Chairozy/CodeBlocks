extends CanvasLayer

class SingleStage:
	var path: String
	var stars: int
	var node: Node
	func _init(_path: String, _stars: int = 0):
		path = _path
		stars = _stars

static var STAGES: Array = []
var currentLevel: int = 0
const PlaygroundTscn = preload("res://Playground.tscn")
const MainMenuTscn = preload("res://MainMenu.tscn")
const BlockingTscn = preload("res://resource/ui/BlockingPanel.tscn")
const WinTscn = preload("res://resource/ui/WinPanel.tscn")
const BlackoutTscn = preload("res://resource/ui/blackout.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	RenderingServer.set_default_clear_color(Color.BLACK)
	layer = 2
	visible = true
	var files_path = DirAccess.get_files_at("res://resource/stages/")
	files_path.sort()
	for filePath in files_path:
		if not filePath.ends_with(".tscn"):
			continue
		STAGES.append(SingleStage.new("res://resource/stages/" + filePath))

func black_out():
	var blackout = BlackoutTscn.instantiate()
	blackout.get_child(0).modulate.a = 0.0
	get_tree().current_scene.add_child(blackout)
	var tween = create_tween()
	tween.tween_property(blackout.get_child(0), "modulate:a", 1.0, 0.3)
	await tween.finished
	blackout.queue_free()

func black_in():
	var blackout = BlackoutTscn.instantiate()
	blackout.get_child(0).modulate.a = 1.0
	get_tree().current_scene.add_child(blackout)
	var tween = create_tween()
	tween.tween_property(blackout.get_child(0), "modulate:a", 0.0, 0.3)
	await tween.finished
	blackout.queue_free()

func home():
	await black_out()
	get_tree().change_scene_to_packed(MainMenuTscn)

func goto_stage(level: int):
	await black_out()
	get_tree().change_scene_to_packed(PlaygroundTscn)
	currentLevel = level
	await get_tree().node_added
	_create_playground()

func restart():
	if currentLevel > 0:
		await black_out()
		get_tree().reload_current_scene()
		await get_tree().node_added
		_create_playground()

func has_stages(level) -> bool:
	return level <= STAGES.size()

func get_single_stage() -> SingleStage:
	return STAGES[currentLevel-1]

func _create_playground():
	var single_stage = STAGES[currentLevel-1]
	single_stage.node = load(single_stage.path).instantiate()
	get_tree().current_scene\
		.get_node("CanvasScene")\
		.add_child(single_stage.node)
	black_in()

func spawn_win_panel(stars: int = 0):
	var winPanel = WinTscn.instantiate()
	winPanel.stars = stars
	get_single_stage().stars = stars
	var canvasLayer = CanvasLayer.new()
	canvasLayer.add_child(BlockingTscn.instantiate())
	canvasLayer.get_child(0).add_child(winPanel)
	get_tree().current_scene.add_child(canvasLayer)
	BlockCodeManager.main_panel.win()

func show_fail_panel(msg):
	BlockCodeManager.main_panel.fail(msg)
	
