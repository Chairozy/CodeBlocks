extends Control

const StageSelectionTscn = preload("res://resource/ui/StageSelection.tscn")
@onready var hflowContainer := %HFlowContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	Game.black_in()
	var i = 0
	for stage in Game.STAGES:
		i += 1
		var stageSelection = StageSelectionTscn.instantiate()
		stageSelection.level = i
		stageSelection.starts = stage.stars
		stageSelection.pressed.connect(goto_stage.bind(i))
		hflowContainer.add_child(stageSelection)

func goto_stage(level: int):
	Game.goto_stage(level)
