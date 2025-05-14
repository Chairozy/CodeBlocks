class_name Stage extends TileMap

var current_level_name: String = ""
@export var blocks_limit := 0
@export var is_preview := false
@export var advances := {}

@export var star1 := false
@export var star2 := false
@export var star3 := false
var is_won := false

func _ready():
	if is_preview:
		_ready_as_preview()
	else:
		is_preview = true
		_ready_as_canvas()

func _ready_as_canvas():
	pass

func _ready_as_preview():
	pass

func win(stars = 0):
	is_won = true
	preview_pause()
	stars += int(star1) + int(star2) + int(star3)
	await get_tree().create_timer(1.5).timeout
	Game.spawn_win_panel(stars)

func fail(msg = ""):
	preview_pause()
	Game.show_fail_panel(msg)

func preview_pause():
	PreviewScene.get_instance().pause()
	await get_tree().create_timer(0.5).timeout
