extends NinePatchRect

@export var level: int = Game.currentLevel
@export var stars: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$Level.text = str(level)
	%StarContainerMain.autoplay = stars > 0
	%StarContainer2.autoplay = stars > 1
	%StarContainer3.autoplay = stars > 2
	if not Game.has_stages(level + 1):
		%NextNode.hide()

func _on_home_node_pressed():
	Game.home()

func _on_next_node_pressed():
	Game.goto_stage(level + 1)

func _on_restart_node_pressed():
	Game.restart()
